import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/database.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'tablet_sizes.dart';
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

Future<void> openHub(WidgetTester tester, [HandsDatabase? db]) async {
  await pumpApp(tester, db);
  await tapAndSettle(tester, find.text('Balloon Touch'));
}

/// From the Practice tab, runs one balloon at [level] and comes back to the
/// hub. [miss] taps beside the balloon first; [stop] leaves the run unpopped.
Future<void> oneRun(
  WidgetTester tester, {
  int level = 1,
  bool miss = false,
  bool stop = false,
}) async {
  await tapAndSettle(tester, find.bySemanticsLabel('Difficulty Level $level'));
  await tapAndSettle(tester, find.text('Start'));
  if (stop) {
    await tester.binding.handlePopRoute();
    await settle(tester);
    return;
  }
  if (miss) {
    await tester.tapAt(
      tester.getTopLeft(find.bySemanticsLabel('Balloon')) -
          const Offset(10, 10),
    );
    await settle(tester);
  }
  await tapAndSettle(tester, find.bySemanticsLabel('Balloon'));
  // Back from the Run summary lands on My progress.
  await tester.binding.handlePopRoute();
  await settle(tester);
  await tapAndSettle(tester, find.text('Practice'));
}

Future<void> openProgress(WidgetTester tester) =>
    tapAndSettle(tester, find.text('My progress'));

final today = DateFormat('d MMM').format(DateTime.now());

Finder stat(Pattern text) => find.bySemanticsLabel(text);

/// A database whose history query never completes.
class StuckDatabase extends HandsDatabase {
  StuckDatabase() : super(NativeDatabase.memory());

  @override
  Future<List<RunRecord>> runs() => Completer<List<RunRecord>>().future;
}

void main() {
  testWidgets('the hub switches between Practice and My progress', (
    tester,
  ) async {
    await openHub(tester);

    await openProgress(tester);
    expect(find.text('Accuracy over time'), findsOneWidget);
    expect(find.text('Start'), findsNothing);

    await tapAndSettle(tester, find.text('Practice'));
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Accuracy over time'), findsNothing);
  });

  testWidgets('My progress shows empty states before the first run', (
    tester,
  ) async {
    await openHub(tester);
    await openProgress(tester);

    expect(find.text('No runs yet'), findsWidgets);
    expect(find.text('No note from your therapist yet'), findsOneWidget);
    expect(find.text('All levels'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^Level \d$')), findsNothing);
    expect(stat('Runs completed 0'), findsOneWidget);
    expect(stat('Accuracy –'), findsOneWidget);
  });

  testWidgets('the level chips filter the stat cards', (tester) async {
    await openHub(tester);
    await oneRun(tester, level: 1);
    await oneRun(tester, level: 2, miss: true);
    await oneRun(tester, level: 3, stop: true);
    await openProgress(tester);

    for (final chip in ['All levels', 'Level 1', 'Level 2', 'Level 3']) {
      expect(find.text(chip), findsOneWidget);
    }
    expect(find.text('Level 4'), findsNothing);
    expect(stat('Accuracy 67%'), findsOneWidget);
    expect(stat('Runs completed 2'), findsOneWidget);
    expect(stat(RegExp(r'^Reaction Time \d+\.\d\d s$')), findsOneWidget);

    await tapAndSettle(tester, find.text('Level 2'));
    expect(stat('Accuracy 50%'), findsOneWidget);
    expect(stat('Runs completed 1'), findsOneWidget);
    expect(find.textContaining(RegExp(r'· L\d$')), findsOneWidget);
    expect(find.text('$today · L2'), findsOneWidget, reason: 'the chart');
    expect(
      find.textContaining(RegExp(r'^Level \d · ')),
      findsOneWidget,
      reason: 'Recent runs',
    );
    expect(find.textContaining(RegExp(r'^Level 2 · ')), findsOneWidget);

    await tapAndSettle(tester, find.text('Level 3'));
    expect(stat('Accuracy –'), findsOneWidget);
    expect(stat('Runs completed 0'), findsOneWidget);
  });

  testWidgets('the chart has a column per completed run, latest highlighted', (
    tester,
  ) async {
    await openHub(tester);
    await oneRun(tester, level: 2, miss: true);
    await oneRun(tester, level: 3, stop: true);
    await oneRun(tester, level: 1);
    await openProgress(tester);

    expect(find.text('$today · L2'), findsOneWidget);
    expect(find.text('$today · L1'), findsOneWidget);
    expect(find.text('$today · L3'), findsNothing, reason: 'stopped');
    expect(find.bySemanticsLabel('$today · L2, 50%'), findsOneWidget);
    expect(
      find.bySemanticsLabel('$today · L1, 100%, latest run'),
      findsOneWidget,
    );
    expect(
      tester.getCenter(find.text('$today · L2')).dx,
      lessThan(tester.getCenter(find.text('$today · L1')).dx),
    );
  });

  testWidgets('a chart too wide to fit shows whole columns, never a cut one', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await openHub(tester);
    for (var i = 0; i < 8; i++) {
      await oneRun(tester);
    }
    for (final size in tabletSizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await openProgress(tester);

      final labels = find.text('$today · L1');
      final chart = tester.getRect(
        find
            .ancestor(of: labels.first, matching: find.byType(Scrollable))
            .first,
      );
      for (final label in labels.evaluate()) {
        final column = tester.getRect(
          find
              .ancestor(
                of: find.byWidget(label.widget),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        final inside =
            column.left >= chart.left - 0.5 &&
            column.right <= chart.right + 0.5;
        final outside =
            column.right <= chart.left + 0.5 ||
            column.left >= chart.right - 0.5;
        expect(
          inside || outside,
          isTrue,
          reason: 'at $size: $column in $chart',
        );
      }
      await tapAndSettle(tester, find.text('Practice'));
    }
  });

  testWidgets('Recent runs lists the latest four, then See all runs', (
    tester,
  ) async {
    await openHub(tester);
    for (final level in [1, 2, 3, 4]) {
      await oneRun(tester, level: level);
    }
    await oneRun(tester, stop: true);
    await openProgress(tester);

    Finder recent(int level, [String end = '']) => find.textContaining(
      RegExp(
        '^Level $level · '
        r'\d+:\d\d'
        '$end'
        r'$',
      ),
    );
    expect(recent(1), findsNothing, reason: 'the oldest of five');
    final rows = [recent(1, ' · Stopped'), recent(4), recent(3), recent(2)];
    for (final row in rows) {
      expect(row, findsOneWidget);
    }
    final ys = [for (final row in rows) tester.getCenter(row).dy];
    expect(ys, orderedEquals([...ys]..sort()), reason: 'newest first');

    await tapAndSettle(tester, find.text('See all runs →'));
    expect(find.text('All runs'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);

    await tapAndSettle(tester, find.byType(ListTile).first);
    expect(find.bySemanticsLabel('Trial 1, Zone: 1'), findsOneWidget);
  });

  testWidgets('numbers count up and columns grow in', (tester) async {
    await openHub(tester);
    await oneRun(tester);
    await tester.tap(find.text('My progress'));
    await tester.pump();
    // Past the start of the tab's fade-through, which hides it at first.
    await tester.pump(const Duration(milliseconds: 150));

    final counted = find.text('100%').evaluate().length;
    final growing = tester.getSize(find.bySemanticsLabel(RegExp('latest')));
    await settle(tester);
    expect(
      find.text('100%').evaluate().length,
      greaterThan(counted),
      reason: 'still counting up',
    );
    expect(find.text('0%'), findsNothing);
    expect(
      tester.getSize(find.bySemanticsLabel(RegExp('latest'))).height,
      greaterThan(growing.height),
    );
  });

  testWidgets('under reduce motion the numbers and columns appear at once', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await openHub(tester);
    await oneRun(tester);
    await tester.tap(find.text('My progress'));
    await tester.pump();
    await tester.pump();

    expect(find.text('0%'), findsNothing);
    final first = tester.getSize(find.bySemanticsLabel(RegExp('latest')));
    await settle(tester);
    expect(tester.getSize(find.bySemanticsLabel(RegExp('latest'))), first);
  });

  testWidgets('a history query that never completes shows skeletons, then '
      "Couldn't load this", (tester) async {
    final db = StuckDatabase();
    addTearDown(db.close);
    await openHub(tester, db);
    await tester.tap(find.text('My progress'));
    await tester.pump();

    expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsWidgets);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text("Couldn't load this"), findsNWidgets(3));
    expect(find.text('No note from your therapist yet'), findsOneWidget);
  });

  testWidgets('My progress, All runs and Run detail fit every tablet size', (
    tester,
  ) async {
    await expectFitsTablets(tester, () async {
      await openHub(tester);
      for (final level in [1, 2, 3, 4]) {
        await oneRun(tester, level: level, miss: true);
      }
      await oneRun(tester, stop: true);
      await openProgress(tester);
    });
    await expectFitsTablets(
      tester,
      () => tapAndSettle(tester, find.text('See all runs →')),
    );
    await expectFitsTablets(
      tester,
      () => tapAndSettle(tester, find.byType(ListTile).first),
    );
  });
}
