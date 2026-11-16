import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/balloon_illustration.dart';
import 'package:hands/main.dart';

Future<void> startRun(WidgetTester tester, {int balloons = 3}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const HandsApp());
  await tester.tap(find.text('Balloon Touch'));
  await tester.pumpAndSettle();
  for (var i = 1; i < balloons; i++) {
    await tester.tap(find.byTooltip('Increase repetitions'));
  }
  await tester.tap(find.text('Start Now'));
  await tester.pumpAndSettle();
}

final balloon = find.bySemanticsLabel('Balloon');

/// The body's centre: the balloon is drawn with its body centred.
Offset bodyCenter(WidgetTester tester) => tester.getCenter(balloon);

/// The knot hangs just under the body (120 wide, 150 tall).
Offset knot(WidgetTester tester) => bodyCenter(tester) + const Offset(0, 83);

/// Inside the balloon's square but off the body.
Offset offBody(WidgetTester tester) =>
    tester.getTopLeft(balloon) + const Offset(4, 4);

Future<void> touch(WidgetTester tester, Offset down, [Offset? up]) async {
  final gesture = await tester.startGesture(down);
  if (up != null) await gesture.moveTo(up);
  await gesture.up();
  await tester.pumpAndSettle();
}

double progress(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
    .value!;

void main() {
  testWidgets('Start Now opens the Exercise screen with one balloon', (
    tester,
  ) async {
    await startRun(tester);

    for (final text in ['H.A.N.D.S', 'Your progress', '0 / 3', 'Finish']) {
      expect(find.text(text), findsOneWidget);
    }
    for (final tooltip in ['Home', 'Pause', 'Settings']) {
      expect(find.byTooltip(tooltip), findsOneWidget);
    }
    expect(balloon, findsOneWidget);
    expect(progress(tester), 0);
  });

  testWidgets('starting and ending on the body pops the balloon', (
    tester,
  ) async {
    await startRun(tester);
    final first = bodyCenter(tester);

    await touch(tester, first);

    expect(find.text('1 / 3'), findsOneWidget);
    expect(progress(tester), closeTo(1 / 3, 1e-9));
    expect(balloon, findsOneWidget);
    expect(bodyCenter(tester), isNot(first));
  });

  testWidgets('a drag that stays on the body pops', (tester) async {
    await startRun(tester);
    await touch(
      tester,
      bodyCenter(tester),
      bodyCenter(tester) + const Offset(20, 30),
    );
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('starting off the body does not pop', (tester) async {
    await startRun(tester);
    await touch(tester, offBody(tester), bodyCenter(tester));
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('starting outside the balloon does not pop', (tester) async {
    await startRun(tester);
    final outside = tester.getTopLeft(balloon) - const Offset(10, 10);
    await touch(tester, outside, bodyCenter(tester));
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('ending off the body does not pop', (tester) async {
    await startRun(tester);
    await touch(tester, bodyCenter(tester), offBody(tester));
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('starting on the knot does not pop', (tester) async {
    await startRun(tester);
    await touch(tester, knot(tester), bodyCenter(tester));
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('a cancelled pointer does not pop', (tester) async {
    await startRun(tester);
    final gesture = await tester.startGesture(bodyCenter(tester));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('a second finger is ignored while the first is down', (
    tester,
  ) async {
    await startRun(tester);
    final first = await tester.startGesture(bodyCenter(tester), pointer: 1);
    final second = await tester.startGesture(bodyCenter(tester), pointer: 2);
    await second.up();
    await tester.pump();
    expect(find.text('0 / 3'), findsOneWidget);

    await first.up();
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('the balloon darkens only while pressed on the body', (
    tester,
  ) async {
    await startRun(tester);
    bool pressed() => tester
        .widget<BalloonIllustration>(find.byType(BalloonIllustration))
        .pressed;

    final off = await tester.startGesture(offBody(tester));
    await tester.pump();
    expect(pressed(), isFalse);
    await off.up();

    final on = await tester.startGesture(bodyCenter(tester));
    await tester.pump();
    expect(pressed(), isTrue);
    await on.cancel();
    await tester.pump();
    expect(pressed(), isFalse);
  });

  testWidgets('popping every balloon opens the finished progress page', (
    tester,
  ) async {
    await startRun(tester);
    for (var i = 0; i < 3; i++) {
      await touch(tester, bodyCenter(tester));
    }

    for (final text in [
      'Your progress',
      '3/3',
      'Session finished',
      'You completed 3 of 3 balloons.',
      'Start New Session',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('Resume Session'), findsNothing);
    expect(find.byType(BalloonIllustration), findsOneWidget);
    expect(progress(tester), 1);

    await tester.tap(find.text('Start New Session'));
    await tester.pumpAndSettle();
    expect(find.text('Start Now'), findsOneWidget);
  });

  // Portrait and landscape tablets, in logical pixels.
  for (final size in const [
    Size(1194, 834),
    Size(834, 1194),
    Size(1280, 800),
    Size(800, 1280),
  ]) {
    testWidgets('Exercise and progress pages fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const HandsApp());
      await tester.tap(find.text('Balloon Touch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Now'));
      await tester.pumpAndSettle();

      final area = Offset.zero & size;
      expect(area.contains(tester.getTopLeft(balloon)), isTrue);
      expect(area.contains(tester.getBottomRight(balloon)), isTrue);

      await touch(tester, bodyCenter(tester));
      expect(find.text('Session finished'), findsOneWidget);
    });
  }
}
