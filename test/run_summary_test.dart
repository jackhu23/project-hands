import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/exercise_screen.dart';
import 'package:hands/balloon_touch/run_summary_screen.dart';
import 'package:hands/balloon_touch/session.dart';
import 'package:hands/database.dart';
import 'package:hands/main.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'tablet_sizes.dart';
import 'test_app.dart';

/// The balloon pulses forever, so pumpAndSettle would never return.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  // Past a Pop's burst and the wait before the summary, then the route.
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await settle(tester);
}

final balloon = find.bySemanticsLabel('Balloon');

/// Starts a run of [balloons] at [level] from the home screen.
Future<void> startRun(
  WidgetTester tester, {
  int balloons = 3,
  int level = 1,
}) async {
  await tapAndSettle(tester, find.text('Balloon Touch'));
  for (var i = 1; i < balloons; i++) {
    await tester.tap(find.byTooltip('More balloons'));
  }
  await tester.tap(find.bySemanticsLabel('Difficulty Level $level'));
  await tapAndSettle(tester, find.text('Start'));
}

Future<void> popBalloon(WidgetTester tester) => tapAndSettle(tester, balloon);

Future<void> endRun(WidgetTester tester) async {
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Pause'));
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'End this run'));
}

/// One synthetic Trial: where its balloon was, its Reaction Time (null if
/// never popped), and where each Miss before it lifted off.
typedef Seed = ({int zone, Offset at, int? rtMs, List<Offset> misses});

Seed seed(int zone, Offset at, int? rtMs, [List<Offset> misses = const []]) =>
    (zone: zone, at: at, rtMs: rtMs, misses: misses);

var _ids = 0;

/// Saves a synthetic Exercise Run on a 1000 × 600 play area, straight to
/// the database, and returns its id.
Future<String> seedRun(
  HandsDatabase db,
  List<Seed> trials, {
  int level = 2,
  int? balloonCount,
  RunOutcome outcome = RunOutcome.completed,
  DateTime? startedAt,
}) async {
  final patient = (await db.select(db.patients).getSingle()).id;
  final start = startedAt ?? DateTime(2026, 11, 27, 14, 5);
  final end = start.add(const Duration(seconds: 31));
  final id = 'run${_ids++}';
  await db
      .into(db.sessions)
      .insert(
        SessionRow(
          id: 's$id',
          patientId: patient,
          startedAt: start,
          endedAt: end,
        ),
      );
  await db
      .into(db.exerciseRuns)
      .insert(
        ExerciseRunRow(
          id: id,
          sessionId: 's$id',
          exercise: 'Balloon Touch',
          difficultyLevel: level,
          balloonCount: balloonCount ?? trials.length,
          areaWidth: 1000,
          areaHeight: 600,
          startedAt: start,
          endedAt: end,
          outcome: outcome,
        ),
      );
  for (final (i, t) in trials.indexed) {
    final trialId = '$id-t$i';
    final shown = start.add(Duration(seconds: i));
    final popped = t.rtMs == null
        ? null
        : shown.add(Duration(milliseconds: t.rtMs!));
    await db
        .into(db.trials)
        .insert(
          TrialRow(
            id: trialId,
            exerciseRunId: id,
            number: i + 1,
            centerX: t.at.dx,
            centerY: t.at.dy,
            bodyWidth: 120,
            bodyHeight: 150,
            zone: t.zone,
            presentedAt: shown,
            completedAt: popped,
            status: popped == null
                ? TrialStatus.unfinished
                : TrialStatus.completed,
          ),
        );
    Future<void> action(
      String aid,
      ActionOutcome o,
      DateTime at,
      Offset up,
    ) async {
      await db
          .into(db.actions)
          .insert(
            ActionRow(
              id: aid,
              trialId: trialId,
              touchdownAt: at,
              liftOffAt: at,
              outcome: o,
            ),
          );
      for (final (seq, p) in [up + const Offset(5, 5), up].indexed) {
        await db
            .into(db.touchSamples)
            .insert(
              TouchSampleRow(
                actionId: aid,
                sequence: seq,
                time: at,
                x: p.dx,
                y: p.dy,
                pressure: 1,
                kind: TouchKind.finger,
              ),
            );
      }
    }

    for (final (j, m) in t.misses.indexed) {
      await action('$trialId-m$j', ActionOutcome.miss, shown, m);
    }
    if (popped != null) {
      await action('$trialId-p', ActionOutcome.pop, popped, t.at);
    }
  }
  return id;
}

/// Opens the Run summary for [runId] as My progress does.
Future<void> openSummary(WidgetTester tester, String runId) async {
  final db = tester.widget<HandsApp>(find.byType(HandsApp)).database;
  unawaited(
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(
            builder: (_) => RunSummaryScreen(database: db, runId: runId),
          ),
        ),
  );
  await settle(tester);
}

/// Three balloons: a Miss then a slow pop near the centre, a fast pop in
/// Zone 3 and a medium one in Zone 2.
final threeTrials = [
  seed(1, const Offset(500, 300), 2000, [const Offset(100, 60)]),
  seed(3, const Offset(800, 450), 1000),
  seed(2, const Offset(300, 200), 1500),
];

String label(int i, String rest) => 'Balloon $i, $rest';

Finder bar(int i) => find.byKey(ValueKey('bar $i'));

void main() {
  group('ways in', () {
    testWidgets('finishing every balloon shows the summary, and Back never '
        'returns into the run', (tester) async {
      await pumpApp(tester);
      await startRun(tester, level: 2);
      for (var i = 0; i < 3; i++) {
        await popBalloon(tester);
      }

      expect(find.byType(RunSummaryScreen), findsOneWidget);
      expect(find.byType(ExerciseScreen), findsNothing);
      expect(find.text('BALLOON TOUCH · RUN SUMMARY'), findsOneWidget);
      expect(find.textContaining(RegExp(r' · Level 2$')), findsOneWidget);
      expect(find.text('3 of 3'), findsOneWidget);
      expect(find.text('RUN COMPLETE'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Go again'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.byType(ExerciseScreen), findsNothing);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('the final pop bursts before the summary', (tester) async {
      await pumpApp(tester);
      await startRun(tester, balloons: 1);
      await tester.tap(balloon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(PopBurst), findsOneWidget);
      expect(find.byType(RunSummaryScreen), findsNothing);
      await settle(tester);
      expect(find.byType(RunSummaryScreen), findsOneWidget);
    });

    testWidgets('End this run shows the stopped summary', (tester) async {
      await pumpApp(tester);
      await startRun(tester);
      await popBalloon(tester);
      await endRun(tester);

      expect(find.text('RUN STOPPED'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('–'), findsNWidgets(2), reason: 'two bars not popped');
      expect(
        find.bySemanticsLabel(RegExp(r'^Balloon 2, zone \d, not popped$')),
        findsNWidgets(2),
        reason: 'its bar and its dot',
      );
      expect(
        find.bySemanticsLabel('Balloon 3, not popped'),
        findsOneWidget,
        reason: 'never reached: a bar but no dot',
      );
      expect(find.text('Go again'), findsOneWidget);
    });

    testWidgets('a Recent runs row on My progress opens its summary', (
      tester,
    ) async {
      final db = await pumpApp(tester);
      await seedRun(db, threeTrials);
      await tapAndSettle(tester, find.text('Balloon Touch'));
      await tapAndSettle(tester, find.text('My progress'));

      final row = find.bySemanticsLabel(
        RegExp(r'^Open run summary, 27 Nov, 14:05, level 2, 75%$'),
      );
      expect(row, findsOneWidget);
      expect(tester.getSize(row).height, greaterThanOrEqualTo(56));
      await tapAndSettle(tester, row);

      expect(find.byType(RunSummaryScreen), findsOneWidget);
      expect(
        find.textContaining(RegExp(r'^27 Nov 2026 · 2:05\sPM · Level 2$')),
        findsOneWidget,
      );
      expect(find.text('Go again'), findsNothing, reason: 'not from a run');

      await tapAndSettle(tester, find.byTooltip('Back to my progress'));
      expect(find.text('Accuracy over time'), findsOneWidget);
    });
  });

  group('buttons', () {
    testWidgets('Go again keeps the Difficulty Level and count', (
      tester,
    ) async {
      await pumpApp(tester);
      await startRun(tester, balloons: 2, level: 3);
      final first = tester
          .widget<ExerciseScreen>(find.byType(ExerciseScreen))
          .session;
      await popBalloon(tester);
      await popBalloon(tester);

      await tapAndSettle(tester, find.text('Go again'));

      final next = tester
          .widget<ExerciseScreen>(find.byType(ExerciseScreen))
          .session;
      expect(next, isNot(same(first)));
      expect(next.exerciseRun.difficultyLevel, 3);
      expect(find.text('0 of 2'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Start'), findsOneWidget, reason: 'back on the hub');
    });

    testWidgets("Back to today's plan goes Home", (tester) async {
      await pumpApp(tester);
      await startRun(tester, balloons: 1);
      await popBalloon(tester);
      await tapAndSettle(tester, find.text("Back to today's plan"));
      expect(find.text("Today's plan"), findsOneWidget);
      expect(find.byType(RunSummaryScreen), findsNothing);
    });

    testWidgets('the header Back after a run goes to My progress', (
      tester,
    ) async {
      await pumpApp(tester);
      await startRun(tester, balloons: 1);
      await popBalloon(tester);
      await tapAndSettle(tester, find.byTooltip('Back to my progress'));
      expect(find.text('Accuracy over time'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text("Today's plan"), findsOneWidget);
    });
  });

  group('content', () {
    testWidgets('the banner and stat cards, with level averages', (
      tester,
    ) async {
      final db = await pumpApp(tester);
      await seedRun(db, [
        seed(1, const Offset(500, 300), 1000),
        seed(1, const Offset(500, 300), 1000, [const Offset(1, 1)]),
      ], startedAt: DateTime(2026, 11, 20));
      // Stopped, at another level, and later: none count.
      await seedRun(
        db,
        [seed(1, const Offset(500, 300), 100)],
        outcome: RunOutcome.stopped,
        startedAt: DateTime(2026, 11, 21),
      );
      await seedRun(
        db,
        [seed(1, const Offset(500, 300), 100)],
        level: 3,
        startedAt: DateTime(2026, 11, 22),
      );
      await seedRun(db, [
        seed(1, const Offset(500, 300), 100),
      ], startedAt: DateTime(2026, 11, 28));
      await openSummary(tester, await seedRun(db, threeTrials));

      expect(find.text('BALLOONS POPPED'), findsOneWidget);
      expect(find.text('3 of 3'), findsOneWidget);
      expect(find.text('0:31 total'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(
        find.text('3 pops · 1 miss · Level 2 average 67%'),
        findsOneWidget,
      );
      expect(find.text('1.50 s'), findsOneWidget);
      expect(
        find.text('Average per balloon · Level 2 average 1.00 s'),
        findsOneWidget,
      );
    });

    testWidgets('the first run at a level has no averages', (tester) async {
      final db = await pumpApp(tester);
      await openSummary(tester, await seedRun(db, threeTrials));
      expect(find.text('3 pops · 1 miss'), findsOneWidget);
      expect(find.text('Average per balloon'), findsOneWidget);
    });

    testWidgets('zero pops', (tester) async {
      final db = await pumpApp(tester);
      await openSummary(
        tester,
        await seedRun(db, [
          seed(1, const Offset(500, 300), null, [const Offset(9, 9)]),
        ], outcome: RunOutcome.stopped),
      );
      expect(find.text('0 of 1'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('No balloons popped this time.'), findsOneWidget);
    });

    testWidgets('no Actions at all shows dashes', (tester) async {
      final db = await pumpApp(tester);
      await openSummary(
        tester,
        await seedRun(db, [
          seed(1, const Offset(500, 300), null),
        ], outcome: RunOutcome.stopped),
      );
      // Accuracy, Reaction Time and the one bar.
      expect(find.text('–'), findsNWidgets(3));
    });

    testWidgets('one bar and one dot per Trial, Miss rings at lift-off', (
      tester,
    ) async {
      final db = await pumpApp(tester);
      await openSummary(tester, await seedRun(db, threeTrials));

      for (final (i, rest) in [
        (1, '2.00 seconds, zone 1, 1 miss'),
        (2, '1.00 seconds, zone 3, first try'),
        (3, '1.50 seconds, zone 2, first try'),
      ]) {
        expect(find.bySemanticsLabel(label(i, rest)), findsNWidgets(2));
      }
      expect(find.text('2.0'), findsOneWidget, reason: 'bar value');
      // The tallest bar fills the plot; the others are in proportion.
      expect(
        tester.getSize(bar(2)).height / tester.getSize(bar(1)).height,
        closeTo(0.5, 0.01),
      );

      final stage = tester.getRect(find.byType(BalloonMap));
      final dot = find.bySemanticsLabel(
        label(2, '1.00 seconds, zone 3, first try'),
      );
      final dotCenter = tester.getCenter(dot.last);
      expect(dotCenter.dx, closeTo(stage.left + stage.width * 0.8, 0.5));
      expect(dotCenter.dy, closeTo(stage.top + stage.height * 0.75, 0.5));
      expect(tester.getSize(dot.last), const Size.square(44));

      final ring = tester.getCenter(
        find.descendant(
          of: find.byType(BalloonMap),
          matching: find.byType(MissRing),
        ),
      );
      expect(ring.dx, closeTo(stage.left + stage.width * 0.1, 0.5));
      expect(ring.dy, closeTo(stage.top + stage.height * 0.1, 0.5));
      expect(find.text('Miss (where the finger lifted)'), findsOneWidget);
    });

    testWidgets('selecting a bar or a dot updates the detail card', (
      tester,
    ) async {
      final db = await pumpApp(tester);
      await openSummary(tester, await seedRun(db, threeTrials));
      expect(find.text('THIS RUN'), findsOneWidget);
      expect(
        find.text('Your fastest balloon was number 2 (1.00 s), in zone 3.'),
        findsOneWidget,
      );

      final first = find.bySemanticsLabel(
        label(1, '2.00 seconds, zone 1, 1 miss'),
      );
      await tapAndSettle(tester, first.first);
      expect(find.text('BALLOON 1'), findsOneWidget);
      expect(
        find.text('2.00 s to pop · Zone 1 · 1 miss before the pop'),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(first.first),
        containsSemantics(isSelected: true),
      );

      // Its dot, tapped again, clears it.
      await tapAndSettle(tester, first.last);
      expect(find.text('THIS RUN'), findsOneWidget);

      await tapAndSettle(
        tester,
        find.bySemanticsLabel(label(2, '1.00 seconds, zone 3, first try')).last,
      );
      expect(
        find.text('1.00 s to pop · Zone 3 · popped first try'),
        findsOneWidget,
      );
      await tapAndSettle(tester, find.text('BALLOON 2'));
      expect(find.text('THIS RUN'), findsOneWidget, reason: 'tapping the card');
    });

    testWidgets('a fastest balloon near the centre says so', (tester) async {
      final db = await pumpApp(tester);
      await openSummary(
        tester,
        await seedRun(db, [seed(1, const Offset(500, 300), 1230)]),
      );
      expect(
        find.text(
          'Your fastest balloon was number 1 (1.23 s), near the centre.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a run that is not found says so, with a way back', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapAndSettle(tester, find.text('Balloon Touch'));
      await tapAndSettle(tester, find.text('My progress'));
      await openSummary(tester, 'missing');
      expect(find.text("This run couldn't be found."), findsOneWidget);
      await tapAndSettle(
        tester,
        find.widgetWithText(OutlinedButton, 'Back to my progress'),
      );
      expect(find.text('Accuracy over time'), findsOneWidget);
    });

    testWidgets('loading shows skeletons', (tester) async {
      final db = StuckDatabase();
      addTearDown(db.close);
      await pumpApp(tester, db);
      await openSummary(tester, 'any');
      expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });
  });

  group('motion', () {
    testWidgets('the entry motion plays only when arriving from a run', (
      tester,
    ) async {
      await pumpApp(tester);
      await startRun(tester, balloons: 1);
      await tester.tap(balloon);
      await tester.pump();
      // Past the burst and the route's own transition, into the entry.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));
      final growing = tester.getSize(bar(1)).height;
      await settle(tester);
      expect(tester.getSize(bar(1)).height, greaterThan(growing));

      final db = tester.widget<HandsApp>(find.byType(HandsApp)).database;
      await openSummary(tester, await seedRun(db, threeTrials));
      final still = tester.getSize(bar(1)).height;
      await settle(tester);
      expect(tester.getSize(bar(1)).height, still, reason: 'from My progress');
    });

    testWidgets('under reduce motion it shows at once', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpApp(tester);
      await startRun(tester, balloons: 1);
      await tester.tap(balloon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      await tester.pump();
      final first = tester.getSize(bar(1)).height;
      await settle(tester);
      expect(tester.getSize(bar(1)).height, first);
    });
  });

  group('fits every tablet', () {
    testWidgets('completed', (tester) async {
      final db = await pumpApp(tester);
      final id = await seedRun(db, threeTrials);
      await expectFitsTablets(tester, () => openSummary(tester, id));
    });

    testWidgets('stopped', (tester) async {
      final db = await pumpApp(tester);
      final id = await seedRun(
        db,
        threeTrials.take(2).toList(),
        balloonCount: 5,
        outcome: RunOutcome.stopped,
      );
      await expectFitsTablets(tester, () => openSummary(tester, id));
    });

    testWidgets('zero pops', (tester) async {
      final db = await pumpApp(tester);
      final id = await seedRun(db, [
        seed(1, const Offset(500, 300), null, [const Offset(9, 9)]),
      ], outcome: RunOutcome.stopped);
      await expectFitsTablets(tester, () => openSummary(tester, id));
    });

    testWidgets('30 Trials, with level averages', (tester) async {
      final db = await pumpApp(tester);
      await seedRun(db, threeTrials, level: 4, startedAt: DateTime(2026));
      final id = await seedRun(db, [
        for (var i = 0; i < 30; i++)
          seed(i % 4 + 1, Offset(30.0 * i + 40, 20.0 * i + 10), 500 + 37 * i, [
            Offset(30.0 * i, 20.0 * i),
          ]),
      ], level: 4);
      await expectFitsTablets(tester, () => openSummary(tester, id));
      expect(find.text('0.5'), findsNothing, reason: 'labels hide when narrow');
      expect(tester.getSize(bar(1)).width, greaterThanOrEqualTo(12));
    });
  });
}

/// A database whose history query never completes.
class StuckDatabase extends HandsDatabase {
  StuckDatabase() : super(NativeDatabase.memory());

  @override
  Future<List<RunRecord>> runs() => Completer<List<RunRecord>>().future;
}
