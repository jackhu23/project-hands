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

/// One row of the run detail.
typedef TrialDetail = ({
  int number,
  int zone,
  Duration? reactionTime,
  OutcomeCounts counts,
});

List<TrialDetail> trialDetails(RunRecord r) => [
  for (final t in r.trials)
    (
      number: t.number,
      zone: t.zone,
      reactionTime: reactionTime(r, t),
      counts: countOutcomes(_actionsOf(r, t)),
    ),
];

/// The history page's summary. Run counts include stopped runs; the metrics
/// use completed runs only and are null when there's nothing to measure.
typedef RunSummary = ({
  int runs,
  int completed,
  int stopped,
  double? accuracy,
  double? overlappingPerRun,
  Duration? reactionTime,
  Duration? popDuration,
});

RunSummary summarize(Iterable<RunRecord> runs) {
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

/// [summarize] for each Difficulty Level played, lowest first.
Map<int, RunSummary> summarizeByLevel(Iterable<RunRecord> runs) => {
  for (final level in {
    for (final r in runs) r.run.difficultyLevel,
  }.toList()..sort())
    level: summarize(runs.where((r) => r.run.difficultyLevel == level)),
};

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

/// A point per completed run, oldest first.
List<AccuracyPoint> accuracySeries(Iterable<RunRecord> runs) => [
  for (final r in runs)
    if (r.run.outcome == RunOutcome.completed)
      if (runAccuracy(r) case final a?)
        (startedAt: r.run.startedAt, level: r.run.difficultyLevel, accuracy: a),
]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
