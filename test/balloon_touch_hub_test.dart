import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/database.dart';
import 'package:hands/balloon_touch/exercise_screen.dart';
import 'package:hands/balloon_touch/hub_screen.dart';
import 'package:hands/theme.dart';

import 'tablet_sizes.dart';
import 'test_app.dart';

/// The balloon pulses forever, so pumpAndSettle would never return.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> openHub(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('Balloon Touch'));
  await settle(tester);
}

Finder level(int n) => find.bySemanticsLabel('Difficulty Level $n');

bool selected(WidgetTester tester, int n) =>
    isSemantics(isSelected: true).matches(tester.getSemantics(level(n)), {});

Gradient? levelGradient(WidgetTester tester, int n) =>
    (tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: level(n),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration)
        .gradient;

String count(WidgetTester tester) => tester
    .getSemantics(find.bySemanticsLabel(RegExp(r'^\d+ balloons$')))
    .label
    .split(' ')
    .first;

bool enabled(WidgetTester tester, String tooltip) =>
    tester
        .widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        )
        .onPressed !=
    null;

bool startEnabled(WidgetTester tester) =>
    tester
        .widget<InkWell>(
          find.ancestor(of: find.text('Start'), matching: find.byType(InkWell)),
        )
        .onTap !=
    null;

/// A database whose remembered Difficulty Level arrives only when the test
/// completes [levels], one Completer per load.
class SlowDatabase extends HandsDatabase {
  SlowDatabase() : super(NativeDatabase.memory());

  final levels = <Completer<int?>>[];

  @override
  Future<int?> lastDifficultyLevel() {
    levels.add(Completer());
    return levels.last.future;
  }
}

Future<void> start(WidgetTester tester) async {
  await tester.tap(find.text('Start'));
  await settle(tester);
}

void main() {
  testWidgets('Balloon Touch on Home opens the Practice tab', (tester) async {
    await openHub(tester);

    expect(find.byType(BalloonTouchHub), findsOneWidget);
    for (final text in ['EXERCISE', 'Balloon Touch', 'Practice']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('My progress'), findsNothing, reason: 'a later issue');
    expect(find.bySemanticsLabel('Carle Health'), findsOneWidget);
  });

  testWidgets('the back button returns Home', (tester) async {
    await openHub(tester);

    await tester.tap(find.byTooltip('Back'));
    await settle(tester);

    expect(find.byType(BalloonTouchHub), findsNothing);
    expect(find.text("Today's plan"), findsOneWidget);
  });

  testWidgets('the system back gesture returns Home', (tester) async {
    await openHub(tester);

    await tester.binding.handlePopRoute();
    await settle(tester);

    expect(find.byType(BalloonTouchHub), findsNothing);
    expect(find.text("Today's plan"), findsOneWidget);
  });

  testWidgets('Watch how shows an empty state', (tester) async {
    await openHub(tester);

    expect(find.text('STEP 1 · WATCH HOW'), findsOneWidget);
    expect(find.text('Demo coming soon'), findsOneWidget);
  });

  testWidgets('four Difficulty Levels, each with its Zone diagram', (
    tester,
  ) async {
    await openHub(tester);

    expect(find.text('STEP 2 · SET UP YOUR RUN'), findsOneWidget);
    for (var n = 1; n <= 4; n++) {
      expect(level(n), findsOneWidget);
      final diagram = tester.widget<ZoneDiagram>(
        find.descendant(of: level(n), matching: find.byType(ZoneDiagram)),
      );
      expect(diagram.level, n);
      expect(
        tester.getSize(level(n)).height,
        greaterThanOrEqualTo(HandsSizes.levelButtonH),
      );
    }
  });

  testWidgets('choosing a Difficulty Level highlights it with the gradient', (
    tester,
  ) async {
    await openHub(tester);
    expect(selected(tester, 1), isTrue);
    expect(levelGradient(tester, 1), HandsGradients.brandButton);

    // Through the semantics tree, as a screen reader would.
    tester.semantics.tap(find.semantics.byLabel('Difficulty Level 3'));
    await tester.pump();

    expect(selected(tester, 3), isTrue);
    expect(levelGradient(tester, 3), HandsGradients.brandButton);
    for (final n in [1, 2, 4]) {
      expect(selected(tester, n), isFalse, reason: 'Level $n');
      expect(levelGradient(tester, n), isNull, reason: 'Level $n');
    }
  });

  testWidgets('the balloon stepper goes from 1 to 30 and no further', (
    tester,
  ) async {
    await openHub(tester);
    expect(count(tester), '1');
    expect(enabled(tester, 'Fewer balloons'), isFalse);

    for (var i = 0; i < 29; i++) {
      await tester.tap(find.byTooltip('More balloons'));
      await tester.pump();
    }
    expect(count(tester), '30');
    expect(enabled(tester, 'More balloons'), isFalse);
    expect(enabled(tester, 'Fewer balloons'), isTrue);

    await tester.tap(find.byTooltip('Fewer balloons'));
    await tester.pump();
    expect(count(tester), '29');
  });

  testWidgets('the finger is shown read-only', (tester) async {
    await openHub(tester);

    final finger = find.text('Finger: Index · set by your therapist');
    expect(finger, findsOneWidget);
    expect(
      find.ancestor(of: finger, matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets('Start begins an Exercise Run at the chosen level and count', (
    tester,
  ) async {
    await openHub(tester);
    await tester.tap(level(2));
    await tester.tap(find.byTooltip('More balloons'));
    await tester.tap(find.byTooltip('More balloons'));
    await tester.pump();

    expect(
      tester
          .getSize(
            find.ancestor(
              of: find.text('Start'),
              matching: find.byType(InkWell),
            ),
          )
          .height,
      HandsSizes.buttonPrimaryH,
    );
    await start(tester);

    final run = tester
        .widget<ExerciseScreen>(find.byType(ExerciseScreen))
        .session
        .exerciseRun;
    expect(run.difficultyLevel, 2);
    expect(run.balloonCount, 3);
  });

  testWidgets('the hub remembers the last Difficulty Level after a restart', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.tap(find.text('Balloon Touch'));
    await settle(tester);
    await tester.tap(level(4));
    await start(tester);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, db);
    await tester.tap(find.text('Balloon Touch'));
    await settle(tester);

    expect(selected(tester, 4), isTrue);
  });

  testWidgets('Start waits for the remembered Difficulty Level to load', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = SlowDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BalloonTouchHub(database: db, patientId: 'P-test'),
      ),
    );

    expect(startEnabled(tester), isFalse, reason: 'while loading');

    await tester.pump(const Duration(seconds: 10));
    expect(find.text("Couldn't load this"), findsOneWidget);
    db.levels.first.complete(3);
    await tester.pump();
    expect(startEnabled(tester), isFalse, reason: 'a load that ended late');

    await tester.tap(find.text('Try again'));
    await tester.pump();
    db.levels.last.complete(3);
    await tester.pump();
    await tester.pump();
    expect(startEnabled(tester), isTrue);
    expect(selected(tester, 3), isTrue);
  });

  testWidgets('the Practice tab fits every tablet size', (tester) async {
    await expectFitsTablets(tester, () => openHub(tester));
  });
}
