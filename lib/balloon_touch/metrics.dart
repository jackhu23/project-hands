import 'dart:ui';

import '../database.dart';
import 'session.dart';

// Metrics over stored Exercise Runs. Pure calculations, kept apart from the
// UI; durations leave out time spent paused.

/// Pops ÷ (Pops + Misses); null when there are neither.
double? accuracy({required int pops, required int misses}) =>
    pops + misses == 0 ? null : pops / (pops + misses);

/// How long [pauses] overlap the span [from] to [to]. A pause never resumed
/// lasts to [to].
Duration pausedBetween(List<PauseRow> pauses, DateTime from, DateTime to) {
  var paused = Duration.zero;
  for (final p in pauses) {
    final start = p.pausedAt.isAfter(from) ? p.pausedAt : from;
    final resumed = p.resumedAt ?? to;
    final end = resumed.isBefore(to) ? resumed : to;
    if (end.isAfter(start)) paused += end.difference(start);
  }
  return paused;
}

/// End minus start, minus paused time.
Duration runDuration(RunRecord r) {
  final end = r.run.endedAt!;
  return end.difference(r.run.startedAt) -
      pausedBetween(r.pauses, r.run.startedAt, end);
}

Iterable<ActionRow> _actionsOf(RunRecord r, TrialRow t) =>
    r.actions.where((a) => a.trialId == t.id);

/// From [t]'s balloon appearing to its Pop's touchdown, minus paused time;
/// null if it wasn't popped.
Duration? reactionTime(RunRecord r, TrialRow t) {
  final pop = _actionsOf(
    r,
    t,
  ).where((a) => a.outcome == ActionOutcome.pop).firstOrNull;
  if (pop == null) return null;
  return pop.touchdownAt.difference(t.presentedAt) -
      pausedBetween(r.pauses, t.presentedAt, pop.touchdownAt);
}

typedef OutcomeCounts = ({int pops, int misses, int overlapping});

OutcomeCounts countOutcomes(Iterable<ActionRow> actions) {
  int count(ActionOutcome o) => actions.where((a) => a.outcome == o).length;
  return (
    pops: count(ActionOutcome.pop),
    misses: count(ActionOutcome.miss),
    overlapping: count(ActionOutcome.overlappingTouch),
  );
}

/// My progress's summary. Run counts include stopped runs; the metrics
/// use completed runs only and are null when there's nothing to measure.
typedef ProgressStats = ({
  int runs,
  int completed,
  int stopped,
  double? accuracy,
  double? overlappingPerRun,
  Duration? reactionTime,
  Duration? popDuration,
});

ProgressStats summarize(Iterable<RunRecord> runs) {
  final done = runs.where((r) => r.run.outcome == RunOutcome.completed);
  final actions = [for (final r in done) ...r.actions];
  final counts = countOutcomes(actions);
  return (
    runs: runs.length,
    completed: done.length,
    stopped: runs.length - done.length,
    accuracy: accuracy(pops: counts.pops, misses: counts.misses),
    overlappingPerRun: done.isEmpty ? null : counts.overlapping / done.length,
    reactionTime: mean([
      for (final r in done)
        for (final t in r.trials) ?reactionTime(r, t),
    ]),
    popDuration: mean([
      for (final a in actions)
        if (a.outcome == ActionOutcome.pop)
          a.liftOffAt.difference(a.touchdownAt),
    ]),
  );
}

/// One column of the All runs summary. Unlike [summarize], Overlapping
/// Touches per run counts every run, stopped ones included; null with none.
typedef RunCounts = ({
  int runs,
  int completed,
  int stopped,
  double? overlappingPerRun,
});

RunCounts countRuns(Iterable<RunRecord> runs) {
  final completed = runs
      .where((r) => r.run.outcome == RunOutcome.completed)
      .length;
  final overlapping = countOutcomes([for (final r in runs) ...r.actions])
      .overlapping;
  return (
    runs: runs.length,
    completed: completed,
    stopped: runs.length - completed,
    overlappingPerRun: runs.isEmpty ? null : overlapping / runs.length,
  );
}

Duration? mean(List<Duration> ds) =>
    ds.isEmpty ? null : ds.reduce((a, b) => a + b) ~/ ds.length;

/// One run's Accuracy over all its Actions.
double? runAccuracy(RunRecord r) {
  final c = countOutcomes(r.actions);
  return accuracy(pops: c.pops, misses: c.misses);
}

/// The runs at Difficulty Level [level], or every run when it's null.
List<RunRecord> atLevel(Iterable<RunRecord> runs, int? level) => [
  for (final r in runs)
    if (level == null || r.run.difficultyLevel == level) r,
];

/// One column of the Accuracy-over-time chart.
typedef AccuracyPoint = ({DateTime startedAt, int level, double accuracy});

/// A point per completed run with any Pops or Misses, oldest first.
List<AccuracyPoint> accuracySeries(Iterable<RunRecord> runs) => [
  for (final r in runs)
    if (r.run.outcome == RunOutcome.completed)
      if (runAccuracy(r) case final a?)
        (startedAt: r.run.startedAt, level: r.run.difficultyLevel, accuracy: a),
]..sort((a, b) => a.startedAt.compareTo(b.startedAt));

/// One Trial on the Run summary. [zone] and [position] (a share of the play
/// area, 0 to 1) are null for a Trial the run stopped before showing, and
/// [reactionTime] is null unless it was popped.
typedef SummaryTrial = ({
  int number,
  int? zone,
  Offset? position,
  Duration? reactionTime,
  int misses,
});

/// One Exercise Run's Run summary. The level averages are [summarize] over
/// the completed runs at its Difficulty Level that started before it, so a
/// summary stays the same over time; null when there are none.
typedef RunSummary = ({
  ExerciseRunRow run,
  bool completed,
  int pops,
  int misses,
  int overlapping,
  double? accuracy,
  Duration? reactionTime,
  Duration duration,
  List<SummaryTrial> trials,
  SummaryTrial? fastest,
  double? levelAccuracy,
  Duration? levelReactionTime,
});

/// [r]'s Run summary, with level averages from [runs].
RunSummary summarizeRun(RunRecord r, Iterable<RunRecord> runs) {
  final run = r.run;
  final counts = countOutcomes(r.actions);
  final byNumber = {for (final t in r.trials) t.number: t};
  final trials = <SummaryTrial>[
    for (var n = 1; n <= run.balloonCount; n++)
      if (byNumber[n] case final t?)
        (
          number: n,
          zone: t.zone,
          position: Offset(
            t.centerX / run.areaWidth,
            t.centerY / run.areaHeight,
          ),
          reactionTime: reactionTime(r, t),
          misses: countOutcomes(_actionsOf(r, t)).misses,
        )
      else
        (number: n, zone: null, position: null, reactionTime: null, misses: 0),
  ];
  SummaryTrial? fastest;
  for (final t in trials) {
    if (t.reactionTime case final rt?
        when fastest == null || rt < fastest.reactionTime!) {
      fastest = t;
    }
  }
  final level = summarize(
    runs.where(
      (o) =>
          o.run.id != run.id &&
          o.run.difficultyLevel == run.difficultyLevel &&
          o.run.startedAt.isBefore(run.startedAt),
    ),
  );
  return (
    run: run,
    completed: run.outcome == RunOutcome.completed,
    pops: counts.pops,
    misses: counts.misses,
    overlapping: counts.overlapping,
    accuracy: accuracy(pops: counts.pops, misses: counts.misses),
    reactionTime: mean([...trials.map((t) => t.reactionTime).nonNulls]),
    duration: runDuration(r),
    trials: trials,
    fastest: fastest,
    levelAccuracy: level.accuracy,
    levelReactionTime: level.reactionTime,
  );
}
