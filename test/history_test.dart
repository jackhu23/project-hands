import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/history_screen.dart';
import 'package:hands/balloon_touch/run_summary_screen.dart';
import 'package:hands/database.dart';
import 'package:hands/main.dart';

import 'run_summary_test.dart' show seed, seedRun, threeTrials;
import 'tablet_sizes.dart';
import 'test_app.dart';

/// The balloon pulses forever, so pumpAndSettle would never return.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await settle(tester);
}

/// Starts a one-balloon run from the home screen.
Future<void> startRun(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Balloon Touch'));
  await tapAndSettle(tester, find.text('Start'));
}

/// Pops the only balloon, which completes the run, on to its Run summary.
Future<void> popBalloon(WidgetTester tester) =>
    tapAndSettle(tester, find.bySemanticsLabel('Balloon'));

/// Pauses the run and ends it, on its Run summary.
Future<void> endRun(WidgetTester tester) async {
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Pause'));
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'End this run'));
}

/// Opens All runs over the current screen; the Go to Practice test covers
/// the way there through My progress.
Future<void> openHistory(WidgetTester tester) async {
  final db = tester.widget<HandsApp>(find.byType(HandsApp)).database;
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .push(
        MaterialPageRoute<void>(builder: (_) => AllRunsScreen(database: db)),
      );
  await settle(tester);
}

/// Closes the app and launches it again on the same database.
Future<void> restart(WidgetTester tester, HandsDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await pumpApp(tester, db);
}

/// Seeds one three-balloon run at each of [levels], a day apart, oldest
/// first, and a stopped one at [stoppedLevel].
Future<void> seedLevels(
  HandsDatabase db,
  List<int> levels, {
  int? stoppedLevel,
}) async {
  for (final (i, level) in levels.indexed) {
    await seedRun(
      db,
      threeTrials,
      level: level,
      startedAt: DateTime(2026, 11, 1 + i, 14, 5),
    );
  }
  if (stoppedLevel != null) {
    await seedRun(
      db,
      [seed(1, const Offset(500, 300), null)],
      level: stoppedLevel,
      balloonCount: 3,
      outcome: RunOutcome.stopped,
      startedAt: DateTime(2026, 11, 20, 9, 30),
    );
  }
}

final rows = find.bySemanticsLabel(RegExp(r'Opens run summary\.$'));

/// The run rows' labels, top to bottom.
List<String> rowLabels(WidgetTester tester) => [
  for (final e in rows.evaluate())
    tester
        .getSemantics(find.byElementPredicate((x) => x == e))
        .label
        // DateFormat puts a narrow no-break space before AM and PM.
        .replaceAll('\u202f', ' '),
];

void main() {
  testWidgets('with no runs, the summary is zeros and Go to Practice opens '
      'the Practice tab', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.text('Balloon Touch'));
    await tapAndSettle(tester, find.text('My progress'));
    await tapAndSettle(tester, find.text('See all runs →'));

    expect(find.text('All runs'), findsOneWidget);
    expect(
      find.text('No runs yet. Your runs will appear here after you practise.'),
      findsOneWidget,
    );
    expect(rows, findsNothing);
    for (final (row, value) in [
      ('Runs', '0'),
      ('Completed', '0'),
      ('Stopped early', '0'),
      ('Overlapping touches / run', '–'),
    ]) {
      expect(find.bySemanticsLabel('$row, All: $value'), findsOneWidget);
    }
    expect(find.text('RUNS BY LEVEL'), findsNothing);

    await tapAndSettle(tester, find.text('Go to Practice'));

    expect(find.byType(AllRunsScreen), findsNothing);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('the summary has All and each level with runs, ascending, '
      'with counts only', (tester) async {
    final db = await pumpApp(tester);
    await seedLevels(db, [4, 2, 2], stoppedLevel: 4);

    await openHistory(tester);

    for (final (column, runs, completed, stopped) in [
      ('All', 4, 3, 1),
      ('Level 2', 2, 2, 0),
      ('Level 4', 2, 1, 1),
    ]) {
      expect(find.bySemanticsLabel('Runs, $column: $runs'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Completed, $column: $completed'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Stopped early, $column: $stopped'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Overlapping touches / run, $column: 0.0'),
        findsOneWidget,
      );
    }
    final headers = [
      'All',
      'Level 2',
      'Level 4',
    ].map((h) => tester.getCenter(find.text(h).first).dx);
    expect(headers, orderedEquals([...headers]..sort()));
    expect(
      find.bySemanticsLabel(RegExp('^(Accuracy|Reaction Time|Pop touch)')),
      findsNothing,
    );
    expect(
      find.bySemanticsLabel('Level 2: 2 runs, 2 completed, 0 stopped'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Level 4: 2 runs, 1 completed, 1 stopped'),
      findsOneWidget,
    );
  });

  testWidgets('with all four levels, the summary headers shorten', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedLevels(db, [1, 2, 3, 4]);

    await openHistory(tester);

    for (final level in [1, 2, 3, 4]) {
      expect(find.text('L$level'), findsOneWidget);
      expect(find.bySemanticsLabel('Runs, Level $level: 1'), findsOneWidget);
    }
  });

  testWidgets('rows are newest first and read out the whole run', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedLevels(db, [2], stoppedLevel: 4);
    await seedRun(
      db,
      threeTrials,
      level: 3,
      startedAt: DateTime(2020, 3, 7, 9, 5),
    );

    await openHistory(tester);

    expect(rowLabels(tester), [
      '20 Nov 9:30 AM, level 4, 0 of 3 popped, no accuracy, 31 seconds, '
          'stopped. Opens run summary.',
      '1 Nov 2:05 PM, level 2, 3 of 3 popped, accuracy 75 percent, '
          '31 seconds, completed. Opens run summary.',
      '7 Mar 2020 9:05 AM, level 3, 3 of 3 popped, accuracy 75 percent, '
          '31 seconds, completed. Opens run summary.',
    ]);
    expect(find.text('STOPPED'), findsOneWidget);
    expect(find.text('COMPLETED'), findsNWidgets(2));
    expect(find.text('7 Mar 2020'), findsOneWidget);
    expect(find.text('1 Nov'), findsOneWidget);
    expect(find.text('3 of 3'), findsNWidgets(2));
    expect(find.text('75%'), findsNWidgets(2));
    expect(find.text('0:31'), findsNWidgets(3));
    for (final e in rows.evaluate()) {
      expect(
        tester.getSize(find.byWidget(e.widget)).height,
        greaterThanOrEqualTo(64),
      );
    }
  });

  testWidgets('the filter changes the table only, and survives opening a run', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedLevels(db, [2, 4, 2]);
    await openHistory(tester);

    // The filter's segment; summary and row text don't form their own nodes.
    await tapAndSettle(tester, find.bySemanticsLabel('Level 4').last);

    expect(rows, findsOneWidget);
    expect(find.bySemanticsLabel('Runs, All: 3'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Level 4').last),
      isSemantics(isButton: true, isSelected: true),
    );
    expect(
      tester.getSize(find.bySemanticsLabel('All levels')).height,
      greaterThanOrEqualTo(48),
    );

    await tapAndSettle(tester, rows);
    expect(find.byType(RunSummaryScreen), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('Back to all runs'));

    expect(find.byType(RunSummaryScreen), findsNothing);
    expect(rows, findsOneWidget, reason: 'still filtered to Level 4');
  });

  testWidgets('the table header stays put while 120 runs scroll', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await seedLevels(db, [for (var i = 0; i < 120; i++) 1 + i % 4]);
    await openHistory(tester);
    final header = tester.getTopLeft(find.text('DATE & TIME'));
    final first = rowLabels(tester).first;

    await tester.drag(rows.first, const Offset(0, -2000));
    await settle(tester);

    expect(tester.getTopLeft(find.text('DATE & TIME')), header);
    expect(rowLabels(tester).first, isNot(first));
  });

  testWidgets('All runs fits every tablet size', (tester) async {
    late HandsDatabase db;
    await expectFitsTablets(tester, () async {
      db = await pumpApp(tester);
      await openHistory(tester);
    });
    await seedLevels(db, [2], stoppedLevel: 2);
    await expectFitsTablets(tester, () => restartAndOpen(tester, db));
    await seedLevels(db, [for (var i = 0; i < 120; i++) 1 + i % 4]);
    await expectFitsTablets(tester, () => restartAndOpen(tester, db));
  });

  testWidgets('End this run lists it as STOPPED', (tester) async {
    await pumpApp(tester);
    await startRun(tester);
    await endRun(tester);
    await tapAndSettle(tester, find.byTooltip('Back to my progress'));

    await openHistory(tester);

    expect(rows, findsOneWidget);
    expect(find.text('0 of 1'), findsOneWidget);
    expect(find.text('STOPPED'), findsOneWidget);
  });

  testWidgets('the system back gesture during a run lists it as STOPPED', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester);
    await tester.binding.handlePopRoute();
    await settle(tester);
    await tapAndSettle(tester, find.byTooltip('Back'));

    await openHistory(tester);

    expect(find.text('STOPPED'), findsOneWidget);
  });

  testWidgets('history survives a restart, newest run first', (tester) async {
    final db = await pumpApp(tester);
    await startRun(tester);
    await popBalloon(tester);
    await restart(tester, db);
    // Left running when the app closed: stopped on the next launch.
    await startRun(tester);
    await restart(tester, db);

    await openHistory(tester);

    expect(rows, findsNWidgets(2));
    expect(
      tester.getCenter(find.text('STOPPED')).dy,
      lessThan(tester.getCenter(find.text('COMPLETED')).dy),
    );
    expect(
      rowLabels(tester).first,
      matches(RegExp(r'^\d+ \w{3} \d+:\d\d [AP]M, level 1, 0 of 1 popped')),
    );
  });

  testWidgets('Clear all data on the Therapist screen empties the history', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester);
    await popBalloon(tester);
    await tapAndSettle(tester, find.text("Back to today's plan"));

    await tapAndSettle(tester, find.text('Therapist'));
    await tapAndSettle(tester, find.text('Clear all data'));
    await openHistory(tester);

    expect(rows, findsNothing);
    expect(find.text('Clear all data'), findsNothing);
  });

  test('formats the duration and accuracy', () {
    expect(formatDuration(const Duration(minutes: 2, seconds: 5)), '2:05');
    expect(formatDuration(const Duration(milliseconds: 900)), '0:00');
    expect(formatDuration(const Duration(hours: 1, minutes: 1)), '61:00');
    expect(formatAccuracy(2 / 3), '67%');
    expect(formatAccuracy(null), '–');
    expect(formatSeconds(const Duration(milliseconds: 1234)), '1.23 s');
    expect(formatSeconds(null), '–');
  });
}

/// Relaunches on [db] and opens All runs, so it loads what was just seeded.
Future<void> restartAndOpen(WidgetTester tester, HandsDatabase db) async {
  await restart(tester, db);
  await openHistory(tester);
}
