import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The landscape tablet sizes every screen must fit, in logical pixels.
const tabletSizes = [Size(1024, 768), Size(1280, 800), Size(1366, 1024)];

/// Pumps a screen with [pumpScreen], then lays it out at each of
/// [tabletSizes] and fails if anything overflows or throws.
Future<void> expectFitsTablets(
  WidgetTester tester,
  Future<void> Function() pumpScreen,
) async {
  addTearDown(tester.view.reset);
  await pumpScreen();
  for (final size in tabletSizes) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'at $size');
  }
}
