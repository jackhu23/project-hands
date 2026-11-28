import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hands/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// Device smoke test: launches the real app on an emulator or simulator and
/// plays one Exercise Run the way a Patient would, saving a screenshot per
/// step. Run it with `flutter drive` (see README, "Testing on the other
/// platform"); the device's own database is used, so it may hold earlier runs.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var shots = 0;

  Future<void> screenshot(WidgetTester tester, String name) async {
    // Android draws through a platform surface the screenshot can't read.
    if (shots == 0 && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
    // Android's capture can hold an old frame until new ones are drawn.
    for (var i = 0; i < 3; i++) {
      binding.scheduleFrame();
      await tester.pump(const Duration(milliseconds: 100));
    }
    await binding.takeScreenshot('${++shots}-$name');
  }

  /// Fails with a screenshot of what was on screen instead.
  Future<Never> failWithScreenshot(WidgetTester tester, String reason) async {
    await screenshot(tester, 'FAILED');
    fail(reason);
  }

  /// Pumps until [finder] shows. The balloon and demo animate forever, so
  /// pumpAndSettle would never return, and devices in CI can be slow.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final end = DateTime.now().add(const Duration(seconds: 30));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        await failWithScreenshot(tester, 'Never appeared: $finder');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> tapWhenShown(WidgetTester tester, Finder finder) async {
    await waitFor(tester, finder);
    await tester.tap(finder.first);
    await tester.pump();
  }

  testWidgets('a Patient plays a run and finds it in My progress', (
    tester,
  ) async {
    await app.main();
    await waitFor(tester, find.text('Balloon Touch'));
    await screenshot(tester, 'home');

    await tapWhenShown(tester, find.text('Balloon Touch'));
    await tapWhenShown(tester, find.bySemanticsLabel('Difficulty Level 1'));
    // Let the Watch how demo reach its Pop.
    await tester.pump(const Duration(seconds: 3));
    await screenshot(tester, 'hub');

    await tapWhenShown(tester, find.text('Start'));
    final balloon = find.bySemanticsLabel('Balloon');
    final summary = find.text('BALLOONS POPPED');
    await waitFor(tester, balloon);
    await screenshot(tester, 'run');
    // Pop every balloon, however many the hub was set to (at most 30).
    final end = DateTime.now().add(const Duration(minutes: 3));
    while (summary.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        await failWithScreenshot(tester, 'The run never ended');
      }
      if (balloon.evaluate().isNotEmpty) {
        await tester.tap(balloon);
        // Past the pop burst, before the next balloon or the summary.
        await tester.pump(const Duration(seconds: 2));
      } else {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
    await waitFor(tester, find.text('RUN COMPLETE'));
    // Past the summary's entry motion: the banner, cards and bars come in.
    await tester.pump(const Duration(seconds: 2));
    await screenshot(tester, 'run-summary');

    await tapWhenShown(tester, find.byTooltip('Back to my progress'));
    final row = find.bySemanticsLabel(RegExp('^Open run summary'));
    await waitFor(tester, row);
    await tester.pump(const Duration(seconds: 1));
    await screenshot(tester, 'my-progress');

    await tapWhenShown(tester, row);
    await waitFor(tester, summary);
    await tester.pump(const Duration(seconds: 1));
    await screenshot(tester, 'run-summary-from-my-progress');
  });
}
