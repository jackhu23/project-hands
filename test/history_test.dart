import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/history_screen.dart';
import 'package:hands/database.dart';
import 'package:hands/main.dart';

import 'test_app.dart';

/// The balloon pulses forever, so pumpAndSettle would never return.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await settle(tester);
}

/// Starts a one-balloon run from the home screen.
Future<void> startRun(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tapAndSettle(tester, find.text('Balloon Touch'));
  await tapAndSettle(tester, find.text('Start'));
}

/// Pops the only balloon, which completes the run.
Future<void> popBalloon(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Balloon'));
  await settle(tester);
}

/// Pauses the run and ends it, back on the hub.
Future<void> endRun(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Pause'));
  await tapAndSettle(tester, find.text('End this run'));
}

/// Opens All runs over the current screen; my_progress_test covers the way
/// there through My progress.
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

final row = find.byType(ListTile);

void main() {
  testWidgets('history shows an empty state before any runs', (tester) async {
    await pumpApp(tester);
    await openHistory(tester);

    expect(find.text('No Exercise Runs yet'), findsOneWidget);
    expect(row, findsNothing);
  });

  testWidgets('history lists the completed run', (tester) async {
    await pumpApp(tester);
    await startRun(tester);
    await popBalloon(tester);

    await openHistory(tester);

    expect(row, findsOneWidget);
    expect(find.text('1 of 1 balloons popped'), findsOneWidget);
    expect(find.text('Stopped'), findsNothing);
    expect(
      find.textContaining(RegExp(r'^\d+ \w{3} \d{4}, \d\d:\d\d$')),
      findsOneWidget,
    );
  });

  testWidgets('End this run lists it as Stopped', (tester) async {
    await pumpApp(tester);
    await startRun(tester);
    await endRun(tester);
    await tapAndSettle(tester, find.byTooltip('Back'));

    await openHistory(tester);

    expect(find.text('0 of 1 balloons popped'), findsOneWidget);
    expect(find.text('Stopped'), findsOneWidget);
  });

  testWidgets('the system back gesture during a run lists it as Stopped', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester);
    await tester.binding.handlePopRoute();
    await settle(tester);
    await tapAndSettle(tester, find.byTooltip('Back'));

    await openHistory(tester);

    expect(find.text('Stopped'), findsOneWidget);
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

    expect(row, findsNWidgets(2));
    expect(find.text('Stopped'), findsOneWidget);
    final stoppedY = tester.getCenter(find.text('Stopped')).dy;
    final completedY = tester.getCenter(find.text('1 of 1 balloons popped')).dy;
    expect(stoppedY, lessThan(completedY));
  });

  testWidgets('history no longer offers Clear all data', (tester) async {
    await pumpApp(tester);
    await startRun(tester);
    await popBalloon(tester);

    await openHistory(tester);

    expect(row, findsOneWidget);
    expect(find.text('Clear all data'), findsNothing);
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

    expect(find.text('No Exercise Runs yet'), findsOneWidget);
    expect(row, findsNothing);
  });

  testWidgets('the summary counts every run but measures completed ones', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester);
    await popBalloon(tester);
    await tapAndSettle(tester, find.text('Go again'));
    await endRun(tester);
    await tapAndSettle(tester, find.byTooltip('Back'));

    await openHistory(tester);

    for (final column in ['Overall', 'Level 1']) {
      expect(find.bySemanticsLabel('Runs, $column: 2'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Completed runs, $column: 1'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Stopped runs, $column: 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Accuracy, $column: 100%'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Overlapping Touches per run, $column: 0.0'),
        findsOneWidget,
      );
      for (final metric in ['Reaction Time', 'Pop touch duration']) {
        expect(
          find.bySemanticsLabel(
            RegExp(
              '^$metric, $column: '
              r'\d+\.\d\d s$',
            ),
          ),
          findsOneWidget,
        );
      }
    }
  });

  testWidgets('tapping a run opens its detail with each Trial and totals', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester);
    await tester.tapAt(
      tester.getTopLeft(find.bySemanticsLabel('Balloon')) -
          const Offset(10, 10),
    );
    await settle(tester);
    await popBalloon(tester);
    await openHistory(tester);

    await tapAndSettle(tester, row);

    expect(find.bySemanticsLabel('Trial 1, Zone: 1'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Trial 1, Reaction Time: \d+\.\d\d s$')),
      findsOneWidget,
    );
    for (final label in ['Trial 1', 'Total']) {
      expect(find.bySemanticsLabel('$label, Pops: 1'), findsOneWidget);
      expect(find.bySemanticsLabel('$label, Misses: 1'), findsOneWidget);
      expect(
        find.bySemanticsLabel('$label, Overlapping Touches: 0'),
        findsOneWidget,
      );
    }
    expect(find.bySemanticsLabel('Total, Accuracy: 50%'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Total, Reaction Time: mean \d+\.\d\d s$'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('^Total, Zone')), findsNothing);
  });

  test('formats the run time and duration', () {
    expect(formatRunTime(DateTime(2026, 3, 7, 9, 5)), '7 Mar 2026, 09:05');
    expect(formatDuration(const Duration(minutes: 2, seconds: 5)), '2:05');
    expect(formatDuration(const Duration(milliseconds: 900)), '0:00');
    expect(formatDuration(const Duration(hours: 1, minutes: 1)), '61:00');
    expect(formatAccuracy(2 / 3), '67%');
    expect(formatAccuracy(null), '–');
    expect(formatSeconds(const Duration(milliseconds: 1234)), '1.23 s');
    expect(formatSeconds(null), '–');
  });
}
