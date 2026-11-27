import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/balloon_illustration.dart';
import 'package:hands/balloon_touch/session.dart';

import 'test_app.dart';

Future<void> advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> press(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await advance(tester);
}

void main() {
  for (final size in const [Size(1194, 834), Size(834, 1194), Size(390, 844)]) {
    testWidgets('Home fits $size and exposes only the available Exercise', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      await tester.pumpAndSettle();
      expect(find.text('My Games'), findsOneWidget);
      expect(find.text('Balloon Pop'), findsOneWidget);
      expect(find.text('Line Tracing'), findsOneWidget);
      expect(find.text('Drag and Drop'), findsOneWidget);
      expect(find.text('Coming later'), findsNWidgets(2));
      for (final button in tester.widgetList<FilledButton>(
        find.byType(FilledButton),
      )) {
        if ((button.child as Text).data == 'Coming later') {
          expect(button.onPressed, isNull);
        }
      }
      await tester.ensureVisible(find.text('View Results'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Home remains usable with large text', (tester) async {
    tester.view.physicalSize = const Size(834, 1194);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View Results'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Home resumes the same paused Session and shows its final result',
    (tester) async {
      tester.view.physicalSize = const Size(1194, 834);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await pumpApp(tester);
      await press(tester, find.text('Start Now'));
      await press(tester, find.byTooltip('Increase repetitions'));
      await press(tester, find.text('Start Now'));
      await press(tester, find.bySemanticsLabel('Balloon'));
      await press(tester, find.byTooltip('Home'));
      await press(tester, find.text('Back to Home'));
      expect(find.text('My Games'), findsOneWidget);
      expect(find.text('1 of 2 balloons popped'), findsOneWidget);
      expect(find.text('Session paused'), findsOneWidget);
      expect(await db.history(), isEmpty);
      await press(tester, find.text('Resume'));
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.byType(BalloonIllustration), findsOneWidget);
      await press(tester, find.bySemanticsLabel('Balloon'));
      await press(tester, find.text('Back to Home'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 2 balloons popped'), findsOneWidget);
      expect(find.text('Resume'), findsNothing);
      final rows = await db.history();
      expect(rows, hasLength(1));
      expect(rows.single.stopped, isFalse);
      await press(tester, find.text('View Results'));
      expect(find.text('2 of 2 balloons popped'), findsOneWidget);
    },
  );

  testWidgets('Home and Results exclude another Patient’s records', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    final other = Session(patientId: 'synthetic-other', balloonCount: 1);
    other.presentNextTrial(const Size(800, 600));
    other.completeTrial(other.exerciseRun.activeTrial!);
    await db.saveSession(other);
    await press(tester, find.text('View Results'));
    await tester.pumpAndSettle();
    expect(find.text('No Exercise Runs yet'), findsOneWidget);
    expect(find.text('1 of 1 balloons popped'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.textContaining('Ready when you are.'), findsOneWidget);
  });

  testWidgets('Profile and Settings provide working actions', (tester) async {
    final db = await pumpApp(tester);
    final patient = await db.select(db.patients).getSingle();
    await press(tester, find.text('Profile'));
    expect(find.text(patient.id), findsOneWidget);
    await press(tester, find.text('Close'));
    await press(tester, find.byTooltip('Settings'));
    await press(tester, find.text('View results'));
    expect(find.text('History'), findsOneWidget);
  });
}
