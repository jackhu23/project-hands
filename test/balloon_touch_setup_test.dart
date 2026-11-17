import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/balloon_illustration.dart';
import 'package:hands/balloon_touch/exercise_screen.dart';
import 'package:hands/theme.dart';

import 'test_app.dart';

Future<void> openSetup(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('Balloon Touch'));
  await tester.pumpAndSettle();
}

Future<void> useScreen(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Text countText(WidgetTester tester) => tester.widget<Text>(
  find.descendant(
    of: find.bySemanticsLabel(RegExp(r'^\d+ repetitions$')),
    matching: find.byType(Text),
  ),
);

Text levelText(WidgetTester tester) => tester.widget<Text>(
  find.descendant(
    of: find.bySemanticsLabel(RegExp(r'^Difficulty Level \d$')),
    matching: find.byType(Text),
  ),
);

bool enabled(WidgetTester tester, String tooltip) =>
    tester
        .widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip).last,
            matching: find.byType(IconButton),
          ),
        )
        .onPressed !=
    null;

void main() {
  testWidgets('home screen shows one square Balloon Touch button top-left', (
    tester,
  ) async {
    await pumpApp(tester);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.white);
    final button = find.ancestor(
      of: find.text('Balloon Touch'),
      matching: find.byType(OutlinedButton),
    );
    expect(button, findsOneWidget);
    final rect = tester.getRect(button);
    expect(rect.width, rect.height);
    expect(rect.width, greaterThanOrEqualTo(200));
    expect(rect.left, lessThan(100));
    expect(rect.top, lessThan(100));
  });

  testWidgets('setup shows the demo layout and the back button returns home', (
    tester,
  ) async {
    await openSetup(tester);

    for (final text in [
      'H.A.N.D.S',
      'Balloon Practice',
      'Touch the balloon',
      'Number of repetitions',
      'Start Now',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.byType(BalloonIllustration), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Start Now'), findsNothing);
    expect(find.text('Balloon Touch'), findsOneWidget);
  });

  testWidgets('system back gesture returns home from setup', (tester) async {
    await openSetup(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Start Now'), findsNothing);
    expect(find.text('Balloon Touch'), findsOneWidget);
  });

  testWidgets('count starts at 1 and stays within 1 to 30', (tester) async {
    await openSetup(tester);

    expect(countText(tester).data, '1');
    expect(enabled(tester, 'Decrease repetitions'), isFalse);
    expect(enabled(tester, 'Increase repetitions'), isTrue);

    for (var i = 0; i < 29; i++) {
      await tester.tap(find.byTooltip('Increase repetitions'));
      await tester.pump();
    }
    expect(countText(tester).data, '30');
    expect(enabled(tester, 'Increase repetitions'), isFalse);

    await tester.tap(find.byTooltip('Decrease repetitions'));
    await tester.pump();
    expect(countText(tester).data, '29');
  });

  testWidgets('Difficulty Level starts at 1 and stays within 1 to 4', (
    tester,
  ) async {
    await openSetup(tester);

    expect(find.text('Difficulty Level'), findsOneWidget);
    expect(levelText(tester).data, '1');
    expect(enabled(tester, 'Decrease Difficulty Level'), isFalse);
    expect(enabled(tester, 'Increase Difficulty Level'), isTrue);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Increase Difficulty Level'));
      await tester.pump();
    }
    expect(levelText(tester).data, '4');
    expect(enabled(tester, 'Increase Difficulty Level'), isFalse);
    expect(enabled(tester, 'Decrease Difficulty Level'), isTrue);

    await tester.tap(find.byTooltip('Decrease Difficulty Level'));
    await tester.pump();
    expect(levelText(tester).data, '3');
  });

  testWidgets('settings sheet changes the same Difficulty Level', (
    tester,
  ) async {
    await openSetup(tester);
    await tester.tap(find.byTooltip('Increase Difficulty Level'));
    await tester.pump();

    await tester.tap(find.byTooltip('Practice settings'));
    await tester.pumpAndSettle();
    expect(find.text('Difficulty Level: 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase Difficulty Level').last);
    await tester.pump();
    expect(find.text('Difficulty Level: 3'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(levelText(tester).data, '3');
  });

  testWidgets('Start Now starts the Exercise Run at the chosen level', (
    tester,
  ) async {
    await openSetup(tester);
    await tester.tap(find.byTooltip('Increase Difficulty Level'));
    await tester.pump();

    await tester.ensureVisible(find.text('Start Now'));
    await tester.tap(find.text('Start Now'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final screen = tester.widget<ExerciseScreen>(find.byType(ExerciseScreen));
    expect(screen.session.exerciseRun.difficultyLevel, 2);
  });

  testWidgets('settings sheet changes the same count', (tester) async {
    await openSetup(tester);

    await tester.tap(find.byTooltip('Practice settings'));
    await tester.pumpAndSettle();
    expect(find.text('Repetitions: 1'), findsOneWidget);

    // The sheet's control is the last one in the tree.
    await tester.tap(find.byTooltip('Increase repetitions').last);
    await tester.tap(find.byTooltip('Increase repetitions').last);
    await tester.pump();
    expect(find.text('Repetitions: 3'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Practice settings'), findsNothing);
    expect(countText(tester).data, '3');
  });

  testWidgets('Start Now opens the Exercise screen with the chosen count', (
    tester,
  ) async {
    await openSetup(tester);
    await tester.tap(find.byTooltip('Increase repetitions'));
    await tester.tap(find.byTooltip('Increase repetitions'));
    await tester.pump();

    await tester.ensureVisible(find.text('Start Now'));
    await tester.tap(find.text('Start Now'));
    // The balloon pulses forever, so pump past the route transition instead.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Start Now'), findsNothing);
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('Start Now uses the shared theme font and colours', (
    tester,
  ) async {
    await openSetup(tester);

    final style = tester.widget<Text>(find.text('Start Now')).style!;
    expect(style.fontFamily, handsFont);
    expect(style.color, HandsColors.ivory);
  });

  // iPad Pro 11" and Pixel Tablet, in logical pixels.
  const layouts = {
    'iPad landscape': (Size(1194, 834), true),
    'iPad portrait': (Size(834, 1194), false),
    'Android tablet landscape': (Size(1280, 800), true),
    'Android tablet portrait': (Size(800, 1280), false),
    'phone landscape': (Size(844, 390), true),
    // Edges of the rule: width >= 700 and wider than tall.
    'exactly 700 wide': (Size(700, 500), true),
    'wide but under 700': (Size(690, 500), false),
    'square at 1000': (Size(1000, 1000), false),
  };
  for (final MapEntry(key: name, value: (size, sideBySide))
      in layouts.entries) {
    testWidgets(
      '$name lays the cards out ${sideBySide ? 'side by side' : 'stacked'}',
      (tester) async {
        await useScreen(tester, size);
        await openSetup(tester);

        final balloon = tester.getCenter(find.text('Touch the balloon'));
        final count = tester.getCenter(find.text('Number of repetitions'));
        if (sideBySide) {
          expect(count.dx, greaterThan(balloon.dx));
        } else {
          expect(count.dy, greaterThan(balloon.dy));
          expect(count.dx, closeTo(balloon.dx, 1));
        }
        // getRect, unlike getSize, includes any scaling, as drawn on screen.
        for (final tooltip in [
          'Decrease Difficulty Level',
          'Increase Difficulty Level',
        ]) {
          final button = tester.getRect(
            find.ancestor(
              of: find.byTooltip(tooltip),
              matching: find.byType(IconButton),
            ),
          );
          expect(button.width, greaterThanOrEqualTo(60), reason: tooltip);
          expect(button.height, greaterThanOrEqualTo(50), reason: tooltip);
        }
      },
    );
  }

  test('balloon body is 1.25 times as tall as it is wide', () {
    const rect = Rect.fromLTWH(10, 20, 120, 150);
    final bounds = balloonBodyPath(rect).getBounds();

    expect(bounds.left, closeTo(10, 0.5));
    expect(bounds.top, closeTo(20, 0.5));
    expect(bounds.width, closeTo(120, 0.5));
    expect(bounds.height, closeTo(150, 0.5));
    expect(balloonBodyPath(rect).contains(rect.center), isTrue);
    expect(balloonBodyPath(rect).contains(rect.topLeft), isFalse);
  });
}
