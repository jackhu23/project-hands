import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tablet_sizes.dart';
import 'test_app.dart';

const _days = [
  'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', //
  'FRIDAY', 'SATURDAY', 'SUNDAY',
];

/// How opaque [finder] is drawn, through every fade above it.
double opacityOf(WidgetTester tester, Finder finder) {
  var opacity = 1.0;
  for (final fade in tester.widgetList<FadeTransition>(
    find.ancestor(of: finder, matching: find.byType(FadeTransition)),
  )) {
    opacity *= fade.opacity.value;
  }
  for (final o in tester.widgetList<Opacity>(
    find.ancestor(of: finder, matching: find.byType(Opacity)),
  )) {
    opacity *= o.opacity;
  }
  return opacity;
}

/// Pumps past the staggered entrances, which start on a timer, and any route
/// transition.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('Home shows the logo, Patient ID, today and Today\'s plan', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    final patientId = await db.launch();
    await settle(tester);

    final now = DateTime.now();
    expect(find.bySemanticsLabel('Carle Health'), findsOneWidget);
    expect(find.text('Patient $patientId'), findsOneWidget);
    expect(
      find.textContaining(
        RegExp('^${_days[now.weekday - 1]} · ${now.day} [A-Z]+\$'),
      ),
      findsOneWidget,
    );
    expect(find.text("Today's plan"), findsOneWidget);
    expect(find.text('History'), findsNothing);
  });

  testWidgets('the Plan checklist says no plan is set yet', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    expect(find.text("Your therapist hasn't set a plan yet"), findsOneWidget);
    expect(find.textContaining('done'), findsNothing);
  });

  testWidgets('the Balloon Touch card opens Balloon Touch', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('Balloon Touch'));
    await settle(tester);

    expect(find.text('Start Now'), findsOneWidget);
  });

  testWidgets('the Tracing and Coming in spring cards do nothing', (
    tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);
    expect(find.text('COMING SOON'), findsOneWidget);
    expect(find.text('COMING IN SPRING'), findsOneWidget);

    for (final card in ['Tracing', 'New exercise']) {
      await tester.tap(find.text(card));
      await settle(tester);
      expect(find.text("Today's plan"), findsOneWidget);
    }
  });

  testWidgets('the Therapist button opens the Therapist screen', (
    tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('Therapist'));
    await settle(tester);

    expect(find.text("Today's plan"), findsNothing);
    // Tests run in debug builds, where it is shown.
    expect(find.text('Clear all data'), findsOneWidget);
  });

  testWidgets('the Exercise cards ease in', (tester) async {
    await pumpApp(tester);

    expect(opacityOf(tester, find.text('New exercise')), lessThan(1));
    await settle(tester);
    expect(opacityOf(tester, find.text('New exercise')), 1);
  });

  testWidgets('the Exercise cards appear at once under reduce motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpApp(tester);

    for (final card in ['Balloon Touch', 'Tracing', 'New exercise']) {
      expect(opacityOf(tester, find.text(card)), 1);
    }
  });

  testWidgets('Home fits every tablet size', (tester) async {
    await expectFitsTablets(tester, () => pumpApp(tester));
  });
}
