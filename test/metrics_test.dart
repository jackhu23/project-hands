import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/metrics.dart';
import 'package:hands/balloon_touch/session.dart';
import 'package:hands/database.dart';

// Synthetic data only: times are milliseconds after a fixed start.
final t0 = DateTime(2026, 1, 1, 9);
DateTime at(int ms) => t0.add(Duration(milliseconds: ms));
const ms = Duration(milliseconds: 1);

TrialRow trial(
  String id, {
  String run = 'r',
  int number = 1,
  int zone = 1,
  int presented = 0,
  TrialStatus status = TrialStatus.completed,
}) => TrialRow(
  id: id,
  exerciseRunId: run,
  number: number,
  centerX: 0,
  centerY: 0,
  bodyWidth: 120,
  bodyHeight: 150,
  zone: zone,
  presentedAt: at(presented),
  status: status,
);

ActionRow action(String trialId, ActionOutcome outcome, int down, int up) =>
    ActionRow(
      id: '$trialId-$down',
      trialId: trialId,
      touchdownAt: at(down),
      liftOffAt: at(up),
      outcome: outcome,
    );

PauseRow pause(int number, int paused, [int? resumed]) => PauseRow(
  exerciseRunId: 'r',
  number: number,
  pausedAt: at(paused),
  resumedAt: resumed == null ? null : at(resumed),
);

RunRecord record({
  String id = 'r',
  int level = 1,
  RunOutcome outcome = RunOutcome.completed,
  int start = 0,
  int end = 60000,
  List<TrialRow> trials = const [],
  List<ActionRow> actions = const [],
  List<PauseRow> pauses = const [],
}) => (
  run: ExerciseRunRow(
    id: id,
    sessionId: 's',
    exercise: 'Balloon Touch',
    difficultyLevel: level,
    balloonCount: 3,
    areaWidth: 1000,
    areaHeight: 600,
    startedAt: at(start),
    endedAt: at(end),
    outcome: outcome,
  ),
  trials: trials,
  actions: actions,
  pauses: pauses,
);

const pop = ActionOutcome.pop,
    miss = ActionOutcome.miss,
    overlapping = ActionOutcome.overlappingTouch;

void main() {
  test('run duration leaves out paused time, including an open pause', () {
    expect(runDuration(record()), const Duration(seconds: 60));
    expect(
      runDuration(record(pauses: [pause(1, 10000, 25000), pause(2, 50000)])),
      const Duration(seconds: 35),
    );
  });

  test('Reaction Time runs from presented to the Pop\'s touchdown, minus '
      'pauses in between', () {
    final t = trial('t', presented: 1000);
    final actions = [
      action('t', miss, 1500, 1600),
      action('t', pop, 4000, 4200),
    ];

    expect(reactionTime(record(trials: [t], actions: actions), t), ms * 3000);
    expect(
      reactionTime(
        record(
          trials: [t],
          actions: actions,
          // Before the balloon, during it, and after the Pop.
          pauses: [
            pause(1, 0, 500),
            pause(2, 2000, 3000),
            pause(3, 5000, 6000),
          ],
        ),
        t,
      ),
      ms * 2000,
    );
    expect(
      reactionTime(record(trials: [t], actions: [actions.first]), t),
      isNull,
    );
  });

  test(
    'run detail lists each Trial with its Zone, Reaction Time and counts',
    () {
      final r = record(
        trials: [
          trial('a', zone: 2),
          trial(
            'b',
            number: 2,
            zone: 1,
            presented: 5000,
            status: TrialStatus.unfinished,
          ),
        ],
        actions: [
          action('a', miss, 100, 200),
          action('a', overlapping, 150, 300),
          action('a', pop, 400, 500),
          action('b', miss, 5100, 5200),
        ],
      );

      final details = trialDetails(r);

      expect(details.map((d) => (d.number, d.zone)), [(1, 2), (2, 1)]);
      expect(details.map((d) => d.reactionTime), [ms * 400, null]);
      expect(details.map((d) => d.counts), [
        (pops: 1, misses: 1, overlapping: 1),
        (pops: 0, misses: 1, overlapping: 0),
      ]);
      expect(countOutcomes(r.actions), (pops: 1, misses: 2, overlapping: 1));
    },
  );

  test('the summary uses completed runs only but counts stopped ones', () {
    final runs = [
      record(
        id: 'r1',
        trials: [trial('a', run: 'r1')],
        actions: [action('a', miss, 100, 200), action('a', pop, 1000, 1100)],
      ),
      record(
        id: 'r2',
        trials: [trial('b', run: 'r2', presented: 0)],
        actions: [
          action('b', overlapping, 100, 900),
          action('b', overlapping, 200, 900),
          action('b', pop, 3000, 3300),
        ],
        pauses: [pause(1, 500, 1500)],
      ),
      record(
        id: 'r3',
        outcome: RunOutcome.stopped,
        trials: [trial('c', run: 'r3')],
        actions: [action('c', miss, 100, 200), action('c', miss, 300, 400)],
      ),
    ];

    final s = summarize(runs);

    expect((s.runs, s.completed, s.stopped), (3, 2, 1));
    expect(s.accuracy, 2 / 3);
    expect(s.overlappingPerRun, 1.0);
    // 1000 ms, and 3000 ms less a 1000 ms pause.
    expect(s.reactionTime, ms * 1500);
    expect(s.popDuration, ms * 200);
  });

  test('the summary groups by Difficulty Level', () {
    final runs = [
      record(id: 'a', level: 2),
      record(id: 'b', level: 1),
      record(id: 'c', level: 2, outcome: RunOutcome.stopped),
    ];

    final byLevel = summarizeByLevel(runs);

    expect(byLevel.keys, [1, 2]);
    expect(
      byLevel.map((l, s) => MapEntry(l, (s.runs, s.completed, s.stopped))),
      {1: (1, 1, 0), 2: (2, 1, 1)},
    );
  });

  test('an empty summary has no metrics', () {
    final s = summarize([record(outcome: RunOutcome.stopped)]);
    expect((s.runs, s.completed, s.stopped), (1, 0, 1));
    expect([
      s.accuracy,
      s.overlappingPerRun,
      s.reactionTime,
      s.popDuration,
    ], everyElement(isNull));
  });

  test(
    'Accuracy is Pops over Pops and Misses, ignoring Overlapping Touches',
    () {
      expect(accuracy(pops: 3, misses: 1), 0.75);
      expect(accuracy(pops: 0, misses: 2), 0);
      expect(accuracy(pops: 0, misses: 0), isNull);
    },
  );

  test('the level filter keeps one Difficulty Level, or all for null', () {
    final runs = [
      record(id: 'a', level: 2),
      record(id: 'b', level: 1),
      record(id: 'c', level: 2, outcome: RunOutcome.stopped),
    ];

    expect(atLevel(runs, 2).map((r) => r.run.id), ['a', 'c']);
    expect(atLevel(runs, 4), isEmpty);
    expect(atLevel(runs, null).map((r) => r.run.id), ['a', 'b', 'c']);
  });

  test('the chart series has one point per completed run, oldest first', () {
    final runs = [
      record(
        id: 'new',
        level: 3,
        start: 2000,
        trials: [trial('n1', run: 'new')],
        actions: [action('n1', pop, 2100, 2200)],
      ),
      record(
        id: 'stopped',
        start: 1500,
        outcome: RunOutcome.stopped,
        trials: [trial('s1', run: 'stopped')],
        actions: [action('s1', miss, 1600, 1700)],
      ),
      record(
        id: 'old',
        level: 2,
        start: 1000,
        trials: [trial('o1', run: 'old')],
        actions: [
          action('o1', miss, 1100, 1150),
          action('o1', overlapping, 1160, 1170),
          action('o1', pop, 1200, 1300),
        ],
      ),
    ];

    expect(accuracySeries(runs), [
      (startedAt: at(1000), level: 2, accuracy: 0.5),
      (startedAt: at(2000), level: 3, accuracy: 1.0),
    ]);
    expect(accuracySeries([]), isEmpty);
  });

  test("a run's Accuracy counts its own Pops and Misses", () {
    expect(
      runAccuracy(
        record(
          trials: [trial('t')],
          actions: [action('t', miss, 0, 10), action('t', pop, 20, 30)],
        ),
      ),
      0.5,
    );
    expect(runAccuracy(record()), isNull);
  });

  group('Run summary', () {
    test('Accuracy and counts leave out Overlapping Touches', () {
      final r = record(
        trials: [trial('a')],
        actions: [
          action('a', miss, 100, 200),
          action('a', overlapping, 300, 400),
          action('a', pop, 500, 600),
        ],
      );
      final s = summarizeRun(r, [r]);
      expect((s.pops, s.misses, s.overlapping), (1, 1, 1));
      expect(s.accuracy, 0.5);
      expect(s.completed, isTrue);
    });

    test('Reaction Time and duration leave out paused time', () {
      final r = record(
        trials: [trial('a'), trial('b', number: 2, presented: 2000)],
        actions: [action('a', pop, 1000, 1100), action('b', pop, 5000, 5100)],
        pauses: [pause(1, 3000, 4000)],
      );
      final s = summarizeRun(r, [r]);
      expect(s.trials.map((t) => t.reactionTime), [ms * 1000, ms * 2000, null]);
      expect(s.reactionTime, ms * 1500);
      expect(s.duration, const Duration(seconds: 59));
    });

    test(
      'the fastest Trial is the lowest Reaction Time, ties to the first',
      () {
        final r = record(
          trials: [
            trial('a'),
            trial('b', number: 2, presented: 2000, zone: 3),
            trial('c', number: 3, presented: 4000),
          ],
          actions: [
            action('a', pop, 900, 1000),
            action('b', miss, 2100, 2200),
            action('b', pop, 2500, 2600),
            action('c', pop, 4500, 4600),
          ],
        );
        final s = summarizeRun(r, [r]);
        expect(s.fastest?.number, 2);
        expect(s.fastest?.zone, 3);
        expect(s.trials.map((t) => t.misses), [0, 1, 0]);
      },
    );

    test('a stopped run lists every Trial, with unreached ones blank', () {
      final r = record(
        outcome: RunOutcome.stopped,
        trials: [
          trial('a'),
          trial('b', number: 2, zone: 2, status: TrialStatus.unfinished),
        ],
        actions: [action('a', pop, 500, 600)],
      );
      final s = summarizeRun(r, [r]);
      expect(s.completed, isFalse);
      expect(s.pops, 1);
      expect(s.trials.map((t) => t.number), [1, 2, 3]);
      expect(s.trials.map((t) => t.zone), [1, 2, null]);
      expect(s.trials.map((t) => t.reactionTime), [ms * 500, null, null]);
    });

    test('zero Pops has no Reaction Time and no fastest Trial', () {
      final misses = record(
        trials: [trial('a', status: TrialStatus.unfinished)],
        actions: [action('a', miss, 100, 200)],
      );
      final none = record(outcome: RunOutcome.stopped);
      expect(summarizeRun(misses, [misses]).accuracy, 0);
      for (final r in [misses, none]) {
        final s = summarizeRun(r, [r]);
        expect(s.reactionTime, isNull);
        expect(s.fastest, isNull);
      }
      expect(summarizeRun(none, [none]).accuracy, isNull);
    });

    test('level averages use earlier completed runs at the same level', () {
      RunRecord popIn(String id, int start, int rtMs, {int level = 1}) =>
          record(
            id: id,
            level: level,
            start: start,
            trials: [trial('$id-t', run: id, presented: start)],
            actions: [
              action('$id-t', miss, start + 10, start + 20),
              action('$id-t', pop, start + rtMs, start + rtMs + 50),
            ],
          );
      final earlier = popIn('e', 0, 1000);
      final stopped = record(
        id: 'x',
        start: 1000,
        outcome: RunOutcome.stopped,
        trials: [trial('x-t', run: 'x', presented: 1000)],
        actions: [action('x-t', pop, 1100, 1200)],
      );
      final otherLevel = popIn('o', 2000, 100, level: 2);
      final current = popIn('c', 3000, 3000);
      final later = popIn('l', 4000, 100);
      final all = [later, current, otherLevel, stopped, earlier];

      final s = summarizeRun(current, all);
      expect(s.levelAccuracy, 0.5);
      expect(s.levelReactionTime, ms * 1000);

      final first = summarizeRun(earlier, all);
      expect(first.levelAccuracy, isNull, reason: 'the first run at level 1');
      expect(first.levelReactionTime, isNull);
    });
  });
}
