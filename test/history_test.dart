import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/history_screen.dart';
import 'package:hands/database.dart';

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
  await tapAndSettle(tester, find.text('Start Now'));
}

/// Pops the only balloon, which completes the run.
Future<void> popBalloon(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Balloon'));
  await settle(tester);
}

Future<void> openHistoryFromHome(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('History'));
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
    await openHistoryFromHome(tester);

    expect(find.text('No Exercise Runs yet'), findsOneWidget);
    expect(row, findsNothing);
  });

  testWidgets('View history on the progress page lists the completed run', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester);
    await popBalloon(tester);

    await tapAndSettle(tester, find.text('View history'));

    expect(row, findsOneWidget);
    expect(find.text('1 of 1 balloons popped'), findsOneWidget);
    expect(find.text('Stopped'), findsNothing);
    expect(
      find.textContaining(RegExp(r'^\d+ \w{3} \d{4}, \d\d:\d\d$')),
      findsOneWidget,
    );
  });

  testWidgets('Start New Session on a paused run lists it as Stopped', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester);
    await tapAndSettle(tester, find.byTooltip('Home'));
    await tapAndSettle(tester, find.text('Start New Session'));
    await tapAndSettle(tester, find.byTooltip('Back'));

    await openHistoryFromHome(tester);

    expect(find.text('0 of 1 balloons popped'), findsOneWidget);
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

    await openHistoryFromHome(tester);

    expect(row, findsNWidgets(2));
    expect(find.text('Stopped'), findsOneWidget);
    final stoppedY = tester.getCenter(find.text('Stopped')).dy;
    final completedY = tester.getCenter(find.text('1 of 1 balloons popped')).dy;
    expect(stoppedY, lessThan(completedY));
  });

  testWidgets('Clear all data empties the history', (tester) async {
    await pumpApp(tester);
    await startRun(tester);
    await popBalloon(tester);
    await tapAndSettle(tester, find.text('View history'));

    await tapAndSettle(tester, find.text('Clear all data'));

    expect(find.text('No Exercise Runs yet'), findsOneWidget);
    expect(row, findsNothing);
  });

  test('formats the run time and duration', () {
    expect(formatRunTime(DateTime(2026, 3, 7, 9, 5)), '7 Mar 2026, 09:05');
    expect(formatDuration(const Duration(minutes: 2, seconds: 5)), '2:05');
    expect(formatDuration(const Duration(milliseconds: 900)), '0:00');
    expect(formatDuration(const Duration(hours: 1, minutes: 1)), '61:00');
  });
}
