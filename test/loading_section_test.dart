import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/theme.dart';
import 'package:hands/widgets/loading_section.dart';
import 'package:skeletonizer/skeletonizer.dart';

Future<void> pumpSection(WidgetTester tester, Future<String> Function() load) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadingSection<String>(
            load: load,
            placeholder: 'placeholder',
            builder: (_, value) => Text(value),
          ),
        ),
      ),
    );

// Skeletonizer's factory builds a private subclass, so byType misses it.
final skeleton = find.byWidgetPredicate((w) => w is Skeletonizer);
final failure = find.text("Couldn't load this");

void main() {
  testWidgets('shows a skeleton of the section while waiting', (tester) async {
    await pumpSection(tester, () => Completer<String>().future);
    await tester.pump();

    expect(skeleton, findsOneWidget);
    expect(find.text('placeholder'), findsOneWidget);
    expect(failure, findsNothing);

    await tester.pump(const Duration(seconds: 9));
    expect(failure, findsNothing);
    // Let the 10 s timeout fire so no timer is left pending.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('says it couldn\'t load after 10 seconds', (tester) async {
    await pumpSection(tester, () => Completer<String>().future);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();

    expect(failure, findsOneWidget);
    expect(find.text('placeholder'), findsNothing);
    expect(skeleton, findsNothing);
  });

  testWidgets('says it couldn\'t load on an error, in neutral colours', (
    tester,
  ) async {
    await pumpSection(tester, () => Future.error(StateError('offline')));
    await tester.pump();

    expect(failure, findsOneWidget);
    expect(tester.widget<Text>(failure).style!.color, HandsColors.inkMuted);
    final retry = tester.getSize(
      find.widgetWithText(OutlinedButton, 'Try again'),
    );
    expect(retry.height, greaterThanOrEqualTo(HandsSizes.minTouch));
  });

  testWidgets('shows the content once it loads', (tester) async {
    await pumpSection(tester, () async => 'loaded');
    await tester.pump();

    expect(find.text('loaded'), findsOneWidget);
    expect(skeleton, findsNothing);
    expect(failure, findsNothing);
  });

  testWidgets('Try again shows the skeleton, then loads again', (tester) async {
    final retry = Completer<String>();
    var calls = 0;
    await pumpSection(tester, () async {
      calls++;
      if (calls == 1) throw StateError('offline');
      return retry.future;
    });
    await tester.pump();
    expect(failure, findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(calls, 2);
    expect(skeleton, findsOneWidget);
    expect(failure, findsNothing);

    retry.complete('loaded');
    await tester.pump();
    expect(find.text('loaded'), findsOneWidget);
    expect(skeleton, findsNothing);
  });
}
