import 'dart:math';
import 'dart:ui';

/// Placement numbers copied from the demo's `BalloonSessionModel`.
const balloonBodyWidth = 120.0, maxPulseScale = 1.03, edgeMargin = 24.0;

const minDifficultyLevel = 1, maxDifficultyLevel = 4;

/// How much of the exercise area's width and height each Zone ellipse spans,
/// from Zone 1 outward; outside the last one is Zone 4. To be tuned with the OT.
const zoneEllipseSpans = [0.25, 0.55, 0.90];

/// The share of balloons placed in the Difficulty Level's own Zone; the rest
/// go in the Zones inside it. To be tuned with the OT.
const ownZoneShare = 0.7;

/// A Zone with less than this share of the usable area counts as having no
/// room, so each balloon needs only a few hundred draws at most.
const minZoneRoom = 0.01;

/// The outermost Zone with room in [usable], sampled on a fixed grid.
int _outermostZoneWithRoom(Rect usable, Size area) {
  const n = 32;
  final counts = List.filled(zoneEllipseSpans.length + 2, 0);
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n; j++) {
      final point = Offset(
        usable.left + (i + 0.5) / n * usable.width,
        usable.top + (j + 0.5) / n * usable.height,
      );
      counts[zoneOf(point, area)]++;
    }
  }
  // Zone 1 holds the centre, so it always counts.
  return max(1, counts.lastIndexWhere((c) => c >= n * n * minZoneRoom));
}

/// The Zone, 1 to 4, that [point] falls in within [area].
int zoneOf(Offset point, Size area) {
  final x = (point.dx - area.width / 2) / (area.width / 2);
  final y = (point.dy - area.height / 2) / (area.height / 2);
  final i = zoneEllipseSpans.indexWhere((span) => x * x + y * y <= span * span);
  return i == -1 ? zoneEllipseSpans.length + 1 : i + 1;
}

/// Where a balloon's centre may go in [area] so that, at full pulse plus the
/// edge margin, it isn't clipped; null when the area is too small.
Rect? usableArea(Size area) {
  const w = balloonBodyWidth, knot = w * 0.085;
  const dx = w / 2 * maxPulseScale + edgeMargin;
  // The knot's height is reserved on both vertical edges, as in the demo.
  const dy = (w * 1.25 / 2 + knot) * maxPulseScale + edgeMargin;
  if (area.width <= dx * 2 || area.height <= dy * 2) return null;
  return Rect.fromLTRB(dx, dy, area.width - dx, area.height - dy);
}

final _secure = Random.secure();

/// A random 128-bit hex ID, standing in for the demo's UUIDs.
String randomId() => List.generate(
  16,
  (_) => _secure.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

enum SessionStatus { running, paused, completed, stopped }

enum TrialStatus { active, completed, interrupted, unfinished }

enum ActionOutcome { pop, miss, overlappingTouch }

enum TouchKind { finger, stylus, mouse }

/// A pointer event as the play area reports it; [position] is in logical
/// pixels from the play area's top-left.
typedef TouchInput = ({
  Duration timeStamp,
  Offset position,
  double pressure,
  TouchKind kind,
});

/// One raw recorded point within an Action.
class TouchSample {
  const TouchSample({
    required this.sequence,
    required this.time,
    required this.position,
    required this.pressure,
    required this.kind,
  });

  final int sequence;
  final DateTime time;
  final Offset position;
  final double pressure;
  final TouchKind kind;
}

/// One continuous touch, from touchdown to lift-off, made during [trial].
/// Only finished Actions are added to their Trial.
class Action {
  Action._(
    this.trial,
    this.touchdownAt,
    this._downStamp, {
    required this.overlapping,
    required this.startedOnBody,
  });

  final id = randomId();
  final Trial trial;
  final DateTime touchdownAt;
  final bool overlapping, startedOnBody;
  final samples = <TouchSample>[];
  late final DateTime liftOffAt;
  late final ActionOutcome outcome;

  // Event time stamps are precise but count from an arbitrary origin, so each
  // sample's time is its offset from touchdown on the wall clock.
  final Duration _downStamp;

  void _add(TouchInput input) => samples.add(
    TouchSample(
      sequence: samples.length,
      time: touchdownAt.add(input.timeStamp - _downStamp),
      position: input.position,
      pressure: input.pressure,
      kind: input.kind,
    ),
  );
}

class Pause {
  Pause(this.pausedAt);

  final DateTime pausedAt;
  DateTime? resumedAt;
}

/// One balloon. [center] is the body's centre within the exercise area.
class Trial {
  Trial({
    required this.number,
    required this.center,
    required this.zone,
    required this.bodyWidth,
  }) : presentedAt = DateTime.now();

  final id = randomId();
  final int number;
  final Offset center;

  /// The Zone the [center] is in.
  final int zone;
  final double bodyWidth;
  final DateTime presentedAt;
  DateTime? completedAt;
  TrialStatus status = TrialStatus.active;
  final actions = <Action>[];

  double get bodyHeight => bodyWidth * 1.25;
}

class ExerciseRun {
  ExerciseRun(this.balloonCount, this.difficultyLevel)
    : assert(
        difficultyLevel >= minDifficultyLevel &&
            difficultyLevel <= maxDifficultyLevel,
      );

  final id = randomId();
  final int balloonCount, difficultyLevel;
  final trials = <Trial>[];
  final pauses = <Pause>[];

  /// The play area the balloons are placed in, in logical pixels.
  Size area = Size.zero;

  int get completedTrials =>
      trials.where((t) => t.status == TrialStatus.completed).length;

  Trial? get activeTrial =>
      trials.where((t) => t.status == TrialStatus.active).lastOrNull;
}

/// An in-memory Session with one Balloon Touch Exercise Run.
class Session {
  Session({
    required this.patientId,
    required int balloonCount,
    int difficultyLevel = minDifficultyLevel,
    Random? random,
    this.onChange,
  }) : exerciseRun = ExerciseRun(balloonCount, difficultyLevel),
       _random = random ?? Random();

  final id = randomId();
  final String patientId;
  final startedAt = DateTime.now();
  final ExerciseRun exerciseRun;
  final Random _random;
  SessionStatus status = SessionStatus.running;
  DateTime? endedAt;

  /// Called after each change worth saving: a balloon shown or popped, a
  /// pause or resume, or the end of the Session.
  final void Function(Session)? onChange;

  /// Finished Actions not yet saved; whoever saves them clears it.
  final unsavedActions = <Action>[];

  /// Actions in progress, by pointer.
  final _touches = <int, Action>{};

  /// Whether the Action that could pop the balloon started on its body.
  bool get pressingBalloon =>
      _touches.values.any((a) => !a.overlapping && a.startedOnBody);

  /// Starts an Action on the balloon showing; one that begins while another
  /// is in progress is an Overlapping Touch.
  void touchDown(int pointer, TouchInput input, {required bool onBody}) {
    final trial = exerciseRun.activeTrial;
    if (status != SessionStatus.running || trial == null) return;
    _touches[pointer] = Action._(
      trial,
      DateTime.now(),
      input.timeStamp,
      overlapping: _touches.isNotEmpty,
      startedOnBody: onBody,
    ).._add(input);
  }

  void touchMove(int pointer, TouchInput input) =>
      _touches[pointer]?._add(input);

  /// Ends an Action: a Pop if it started and ends on the body and isn't an
  /// Overlapping Touch, which completes its Trial; otherwise a Miss. Returns
  /// the outcome, or null when no Action was in progress.
  ActionOutcome? touchUp(
    int pointer,
    TouchInput input, {
    required bool onBody,
  }) {
    final action = _touches.remove(pointer);
    if (action == null) return null;
    action._add(input);
    _finish(
      action,
      action.samples.last.time,
      action.overlapping
          ? ActionOutcome.overlappingTouch
          : action.startedOnBody && onBody
          ? ActionOutcome.pop
          : ActionOutcome.miss,
    );
    if (action.outcome == ActionOutcome.pop) completeTrial(action.trial);
    return action.outcome;
  }

  void _finish(Action action, DateTime liftOffAt, ActionOutcome outcome) {
    action
      ..liftOffAt = liftOffAt
      ..outcome = outcome;
    action.trial.actions.add(action);
    unsavedActions.add(action);
  }

  /// Ends every touch still down at [at]. One cut off can't be a Pop: it is an
  /// Overlapping Touch if [overlapping] or it was one, otherwise a Miss.
  void _cutOffTouches(DateTime at, {bool overlapping = false}) {
    for (final action in _touches.values) {
      _finish(
        action,
        at,
        overlapping || action.overlapping
            ? ActionOutcome.overlappingTouch
            : ActionOutcome.miss,
      );
    }
    _touches.clear();
  }

  /// A cancelled touch is not an Action.
  void touchCancel(int pointer) => _touches.remove(pointer);

  /// Shows the next balloon at a random spot inside [area] for the Difficulty
  /// Level, unless one is already showing, none remain, or the area is too small.
  void presentNextTrial(Size area) {
    final run = exerciseRun;
    if (status != SessionStatus.running ||
        run.activeTrial != null ||
        run.completedTrials >= run.balloonCount) {
      return;
    }
    final usable = usableArea(area);
    if (usable == null) return;
    run.area = area;

    // On a phone the outermost Zone with room can be below the level.
    final top = min(run.difficultyLevel, _outermostZoneWithRoom(usable, area));
    // Otherwise uniform over Zones 1 to top−1, so each gets a share by its area.
    final own = top == 1 || _random.nextDouble() < ownZoneShare;
    final outermost = own ? top : top - 1;
    // Rejection sampling within the box around the outermost allowed Zone.
    final bounds = outermost > zoneEllipseSpans.length
        ? usable
        : usable.intersect(
            Rect.fromCenter(
              center: area.center(Offset.zero),
              width: area.width * zoneEllipseSpans[outermost - 1],
              height: area.height * zoneEllipseSpans[outermost - 1],
            ),
          );
    Offset center;
    int zone;
    do {
      center = Offset(
        bounds.left + _random.nextDouble() * bounds.width,
        bounds.top + _random.nextDouble() * bounds.height,
      );
      zone = zoneOf(center, area);
    } while (own ? zone != top : zone >= top);

    run.trials.add(
      Trial(
        number: run.completedTrials + 1,
        center: center,
        zone: zone,
        bodyWidth: balloonBodyWidth,
      ),
    );
    onChange?.call(this);
  }

  /// Pops [trial]; completes the Session once every balloon is popped.
  void completeTrial(Trial trial) {
    if (status != SessionStatus.running || trial != exerciseRun.activeTrial) {
      return;
    }
    final now = DateTime.now();
    trial
      ..status = TrialStatus.completed
      ..completedAt = now;
    if (exerciseRun.completedTrials >= exerciseRun.balloonCount) {
      status = SessionStatus.completed;
      endedAt = now;
      // Any touch still down began during the pop, so it is an Overlapping
      // Touch; it is cut off here, as the run is over.
      _cutOffTouches(now, overlapping: true);
    }
    onChange?.call(this);
  }

  /// Pauses the run, cutting off any touch in progress so a hold from before
  /// the pause can't pop the balloon after it.
  void pause() {
    if (status != SessionStatus.running) return;
    status = SessionStatus.paused;
    final now = DateTime.now();
    exerciseRun.pauses.add(Pause(now));
    _cutOffTouches(now);
    onChange?.call(this);
  }

  void resume() {
    if (status != SessionStatus.paused) return;
    status = SessionStatus.running;
    exerciseRun.pauses.last.resumedAt = DateTime.now();
    onChange?.call(this);
  }

  /// Ends the Session early; the balloon showing, if any, becomes unfinished.
  void stop() {
    if (status != SessionStatus.running && status != SessionStatus.paused) {
      return;
    }
    final now = DateTime.now();
    _cutOffTouches(now);
    exerciseRun.activeTrial?.status = TrialStatus.unfinished;
    status = SessionStatus.stopped;
    endedAt = now;
    onChange?.call(this);
  }
}
