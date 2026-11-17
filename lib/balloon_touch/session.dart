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

/// The Zone, 1 to 4, that [point] falls in within [area].
int zoneOf(Offset point, Size area) {
  final x = (point.dx - area.width / 2) / (area.width / 2);
  final y = (point.dy - area.height / 2) / (area.height / 2);
  final i = zoneEllipseSpans.indexWhere((span) => x * x + y * y <= span * span);
  return i == -1 ? zoneEllipseSpans.length + 1 : i + 1;
}

final _secure = Random.secure();

/// A random 128-bit hex ID, standing in for the demo's UUIDs.
String randomId() => List.generate(
  16,
  (_) => _secure.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

enum SessionStatus { running, paused, completed, stopped }

enum TrialStatus { active, completed, interrupted, unfinished }

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
  /// pause, or the end of the Session.
  final void Function(Session)? onChange;

  /// Shows the next balloon at a random spot inside [area] for the Difficulty
  /// Level, unless one is already showing, none remain, or the area is too small.
  void presentNextTrial(Size area) {
    final run = exerciseRun;
    if (status != SessionStatus.running ||
        run.activeTrial != null ||
        run.completedTrials >= run.balloonCount) {
      return;
    }
    const w = balloonBodyWidth, h = w * 1.25, knot = w * 0.085;
    const dx = w / 2 * maxPulseScale + edgeMargin;
    // The knot's height is reserved on both vertical edges, as in the demo.
    const dy = (h / 2 + knot) * maxPulseScale + edgeMargin;
    if (area.width <= dx * 2 || area.height <= dy * 2) return;
    run.area = area;

    final usable = Rect.fromLTRB(dx, dy, area.width - dx, area.height - dy);
    final level = run.difficultyLevel;
    // Otherwise uniform over Zones 1 to N−1, so each gets a share by its area.
    var own = level == 1 || _random.nextDouble() < ownZoneShare;
    Offset center;
    for (var tries = 1; ; tries++) {
      // On a small screen the insets can cover all of Zone N; Zone 1, holding
      // the centre, always has room.
      if (tries > 1000) own = false;
      final outermost = own ? level : level - 1;
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
      center = Offset(
        bounds.left + _random.nextDouble() * bounds.width,
        bounds.top + _random.nextDouble() * bounds.height,
      );
      final zone = zoneOf(center, area);
      if (own ? zone == level : zone < level) break;
    }

    run.trials.add(
      Trial(
        number: run.completedTrials + 1,
        center: center,
        zone: zoneOf(center, area),
        bodyWidth: w,
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
    }
    onChange?.call(this);
  }

  void pause() {
    if (status != SessionStatus.running) return;
    status = SessionStatus.paused;
    onChange?.call(this);
  }

  void resume() {
    if (status == SessionStatus.paused) status = SessionStatus.running;
  }

  /// Ends the Session early; the balloon showing, if any, becomes unfinished.
  void stop() {
    if (status != SessionStatus.running && status != SessionStatus.paused) {
      return;
    }
    exerciseRun.activeTrial?.status = TrialStatus.unfinished;
    status = SessionStatus.stopped;
    endedAt = DateTime.now();
    onChange?.call(this);
  }
}
