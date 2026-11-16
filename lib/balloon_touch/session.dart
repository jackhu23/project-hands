import 'dart:math';
import 'dart:ui';

/// Placement numbers copied from the demo's `BalloonSessionModel`.
const balloonBodyWidth = 120.0, maxPulseScale = 1.03, edgeMargin = 24.0;

final _secure = Random.secure();

/// A random 128-bit hex ID, standing in for the demo's UUIDs.
String randomId() => List.generate(
  16,
  (_) => _secure.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

/// Temporary random Patient ID, kept for as long as the app runs, as in the demo.
final temporaryPatientId = randomId();

enum SessionStatus { running, paused, completed, stopped }

enum TrialStatus { active, completed, interrupted, unfinished }

/// One balloon. [center] is the body's centre within the exercise area.
class Trial {
  Trial({required this.number, required this.center, required this.bodyWidth})
    : presentedAt = DateTime.now();

  final int number;
  final Offset center;
  final double bodyWidth;
  final DateTime presentedAt;
  DateTime? completedAt;
  TrialStatus status = TrialStatus.active;

  double get bodyHeight => bodyWidth * 1.25;
}

class ExerciseRun {
  ExerciseRun(this.balloonCount);

  final int balloonCount;
  final trials = <Trial>[];

  int get completedTrials =>
      trials.where((t) => t.status == TrialStatus.completed).length;

  Trial? get activeTrial =>
      trials.where((t) => t.status == TrialStatus.active).lastOrNull;
}

/// An in-memory Session with one Balloon Touch Exercise Run.
class Session {
  Session({required this.patientId, required int balloonCount, Random? random})
    : exerciseRun = ExerciseRun(balloonCount),
      _random = random ?? Random();

  final id = randomId();
  final String patientId;
  final startedAt = DateTime.now();
  final ExerciseRun exerciseRun;
  final Random _random;
  SessionStatus status = SessionStatus.running;
  DateTime? endedAt;

  /// Shows the next balloon at a uniformly random spot inside [area], unless
  /// one is already showing, none remain, or the area is too small.
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

    run.trials.add(
      Trial(
        number: run.completedTrials + 1,
        center: Offset(
          dx + _random.nextDouble() * (area.width - dx * 2),
          dy + _random.nextDouble() * (area.height - dy * 2),
        ),
        bodyWidth: w,
      ),
    );
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
  }
}
