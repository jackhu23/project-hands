import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/balloon_illustration.dart';
import 'package:hands/balloon_touch/exercise_demo.dart';
import 'package:hands/balloon_touch/exercise_screen.dart';

final hand = find.byKey(ExerciseDemo.handKey);

/// The hand's fingertip: the top-left of its zero-size paint box.
Offset fingertip(WidgetTester tester) => tester.getTopLeft(hand);

Future<void> pumpDemo(
  WidgetTester tester, {
  VoidCallback? onDone,
  bool still = false,
}) => tester.pumpWidget(
  MediaQuery(
    data: MediaQueryData(disableAnimations: still),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 800,
          height: 500,
          child: ExerciseDemo(onDone: onDone),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('plays a Pop, then a Miss, then calls onDone once', (
    tester,
  ) async {
    var done = 0;
    await pumpDemo(tester, onDone: () => done++);
    expect(hand, findsOneWidget);

    await tester.pump(ExerciseDemo.popAt + const Duration(milliseconds: 1));
    expect(find.byType(PopBurst), findsOneWidget);
    expect(find.byType(BalloonIllustration), findsNothing, reason: 'popped');
    expect(find.byType(MissMarker), findsNothing);

    await tester.pump(ExerciseDemo.missAt - ExerciseDemo.popAt);
    expect(find.byType(MissMarker), findsOneWidget);
    expect(find.byType(PopBurst), findsNothing);
    expect(
      find.byType(BalloonIllustration),
      findsOneWidget,
      reason: 'a Miss leaves the balloon',
    );
    expect(done, 0);

    await tester.pump(ExerciseDemo.length - ExerciseDemo.missAt);
    expect(done, 1);
    await tester.pump(const Duration(seconds: 12));
    expect(done, 1, reason: 'plays once');
    expect(find.byType(PopBurst), findsNothing);
  });

  testWidgets('without onDone it loops', (tester) async {
    await pumpDemo(tester);
    await tester.pump(
      ExerciseDemo.length * 2 +
          ExerciseDemo.popAt +
          const Duration(milliseconds: 1),
    );
    expect(find.byType(PopBurst), findsOneWidget);
  });

  testWidgets('the fingertip touches the balloon to Pop it', (tester) async {
    await pumpDemo(tester);
    await tester.pump(ExerciseDemo.popAt - const Duration(milliseconds: 1));
    final balloon = tester.getCenter(find.byType(BalloonIllustration));
    expect((fingertip(tester) - balloon).distance, lessThan(1));
  });

  testWidgets('the Miss is where the fingertip touches, outside the balloon', (
    tester,
  ) async {
    await pumpDemo(tester);
    await tester.pump(ExerciseDemo.missAt + const Duration(milliseconds: 1));
    final lift = tester.getCenter(find.byType(MissMarker));
    expect((fingertip(tester) - lift).distance, lessThan(1));

    final box = tester.getRect(find.byType(BalloonIllustration));
    final width = tester
        .widget<BalloonIllustration>(find.byType(BalloonIllustration))
        .bodyWidth;
    expect(
      balloonReachContains(
        balloonBodyRect(box.size, width),
        lift - box.topLeft,
      ),
      isFalse,
    );
  });

  testWidgets('captions say ✓ after the Pop and ✗ after the Miss', (
    tester,
  ) async {
    final pop = find.text('Touch the balloon to pop it');
    final miss = find.text('Touching beside it is a miss');
    await pumpDemo(tester);
    expect(pop, findsNothing);
    await tester.pump(ExerciseDemo.popAt + const Duration(milliseconds: 500));
    expect(pop, findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(miss, findsNothing);
    await tester.pump(ExerciseDemo.missAt - ExerciseDemo.popAt);
    expect(pop, findsNothing);
    expect(miss, findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('the hand moves', (tester) async {
    await pumpDemo(tester);
    final start = fingertip(tester);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(fingertip(tester), isNot(start));
  });

  testWidgets('stands still on the Miss under reduce motion, and still ends', (
    tester,
  ) async {
    var done = 0;
    await pumpDemo(tester, onDone: () => done++, still: true);
    final start = fingertip(tester);
    expect(
      (start - tester.getCenter(find.byType(MissMarker))).distance,
      lessThan(1),
    );
    expect(find.text('Touch the balloon to pop it'), findsOneWidget);
    expect(find.text('Touching beside it is a miss'), findsOneWidget);
    for (var ms = 0; ms < ExerciseDemo.length.inMilliseconds; ms += 100) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PopBurst), findsNothing);
      if (done == 0) expect(fingertip(tester), start);
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(done, 1);
  });
}
