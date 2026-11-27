import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/balloon_illustration.dart';
import 'package:hands/balloon_touch/exercise_screen.dart';
import 'package:hands/theme.dart';

import 'tablet_sizes.dart';
import 'test_app.dart';

/// The balloon pulses forever, so pumpAndSettle would never return; this
/// pumps past any route transition instead.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> startRun(WidgetTester tester, {int balloons = 3}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(tester);
  await tester.tap(find.text('Balloon Touch'));
  await settle(tester);
  for (var i = 1; i < balloons; i++) {
    await tester.tap(find.byTooltip('More balloons'));
  }
  await tester.tap(find.text('Start'));
  await settle(tester);
}

final balloon = find.bySemanticsLabel('Balloon');

/// The body's centre: the balloon is drawn with its body centred.
Offset bodyCenter(WidgetTester tester) => tester.getCenter(balloon);

/// The same spot, allowing for rounding through the pulse's transform.
Matcher sameSpot(Offset spot) => isA<Offset>().having(
  (o) => (o - spot).distance,
  'distance',
  lessThan(1e-6),
);

/// The knot hangs just under the body (120 wide, 150 tall).
Offset knot(WidgetTester tester) => bodyCenter(tester) + const Offset(0, 83);

/// Inside the balloon's square but off the body.
Offset offBody(WidgetTester tester) =>
    tester.getTopLeft(balloon) + const Offset(4, 4);

Future<void> touch(WidgetTester tester, Offset down, [Offset? up]) async {
  final gesture = await tester.startGesture(down);
  if (up != null) await gesture.moveTo(up);
  await gesture.up();
  await settle(tester);
}

Future<void> touchWith(
  WidgetTester tester,
  Offset at, {
  int? pointer,
  PointerDeviceKind kind = PointerDeviceKind.touch,
  int buttons = kPrimaryButton,
}) async {
  final gesture = await tester.startGesture(
    at,
    pointer: pointer,
    kind: kind,
    buttons: buttons,
  );
  await gesture.up();
  await settle(tester);
}

/// The progress page's bar.
double progress(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
    .value!;

/// The run's progress pill bar.
double runProgress(WidgetTester tester) => tester
    .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
    .widthFactor!;

/// The play area the balloons are placed in.
Rect playArea(WidgetTester tester) => tester.getRect(
  find.ancestor(of: balloon, matching: find.byType(DecoratedBox)).first,
);

Animation<double>? motion(WidgetTester tester) =>
    tester.widget<BalloonIllustration>(find.byType(BalloonIllustration)).motion;

void main() {
  testWidgets('Start opens the run on the branded stage with one balloon', (
    tester,
  ) async {
    await startRun(tester);

    expect(find.bySemanticsLabel('Carle Health'), findsOneWidget);
    expect(find.text('0 of 3'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Pause'), findsOneWidget);
    for (final tooltip in ['Home', 'Finish']) {
      expect(find.byTooltip(tooltip), findsOneWidget);
    }
    expect(find.text('H.A.N.D.S'), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
    expect(balloon, findsOneWidget);
    expect(runProgress(tester), 0);

    // Inset 24 px at the sides and bottom, under the 104 px top band.
    expect(playArea(tester), const Rect.fromLTRB(24, 104, 1256, 776));
    final stage = tester.widget<DecoratedBox>(
      find.ancestor(of: balloon, matching: find.byType(DecoratedBox)).first,
    );
    expect((stage.decoration as BoxDecoration).gradient, HandsGradients.stage);
  });

  testWidgets('every balloon of a run appears inside the play area', (
    tester,
  ) async {
    await startRun(tester, balloons: 10);
    for (var i = 0; i < 10; i++) {
      final c = bodyCenter(tester);
      // Body and knot at the largest pulse; the string may be cut off.
      final drawn = Rect.fromLTRB(c.dx - 62, c.dy - 78, c.dx + 62, c.dy + 138);
      expect(playArea(tester).intersect(drawn), drawn, reason: '#$i');
      await touch(tester, c);
    }
  });

  testWidgets('a Pop plays the burst, then the next balloon appears', (
    tester,
  ) async {
    await startRun(tester);
    final c = bodyCenter(tester);
    await tester.tapAt(c);
    await tester.pump();

    final burst = find.byType(PopBurst);
    expect(burst, findsOneWidget);
    expect(tester.getCenter(burst), sameSpot(c));
    expect(tester.getSize(burst), const Size.square(200));
    expect(balloon, findsNothing);
    expect(find.text('1 of 3'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 450));
    expect(balloon, findsNothing);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(burst, findsNothing);
    expect(balloon, findsOneWidget);
  });

  testWidgets('a Miss shows a grey ring at the lift-off point for 300 ms', (
    tester,
  ) async {
    await startRun(tester);
    final off = offBody(tester);
    final gesture = await tester.startGesture(bodyCenter(tester));
    await gesture.moveTo(off);
    await gesture.up();
    await tester.pump();

    final ring = find.byType(MissRing);
    expect(ring, findsOneWidget);
    expect(tester.getCenter(ring), sameSpot(off));
    expect(balloon, findsOneWidget, reason: 'nothing waits on the ring');
    await tester.pump(const Duration(milliseconds: 310));
    expect(ring, findsNothing);
    expect(find.text('0 of 3'), findsOneWidget);
  });

  testWidgets('a Pop shows no Miss ring', (tester) async {
    await startRun(tester);
    await tester.tapAt(bodyCenter(tester));
    await tester.pump();
    expect(find.byType(MissRing), findsNothing);
  });

  testWidgets('an Overlapping Touch shows no Miss ring', (tester) async {
    await startRun(tester);
    final first = await tester.startGesture(offBody(tester), pointer: 1);
    final second = await tester.startGesture(bodyCenter(tester), pointer: 2);
    await second.up();
    await tester.pump();
    expect(find.byType(MissRing), findsNothing);
    await first.up();
  });

  testWidgets('a touch during the burst does nothing', (tester) async {
    await startRun(tester);
    final c = bodyCenter(tester);
    await tester.tapAt(c);
    await tester.pump();
    await tester.tapAt(c);
    await tester.pump();
    expect(find.byType(MissRing), findsNothing);
    await settle(tester);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(balloon, findsOneWidget);
  });

  testWidgets('pausing mid-burst still brings the next balloon on Resume', (
    tester,
  ) async {
    await startRun(tester);
    await tester.tapAt(bodyCenter(tester));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await settle(tester);
    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(find.byType(PopBurst), findsNothing);
    expect(balloon, findsOneWidget);
  });

  testWidgets('the balloon shines and its string sways', (tester) async {
    await startRun(tester);
    final clock = motion(tester)!;
    final before = clock.value;
    await tester.pump(const Duration(milliseconds: 300));
    expect(clock.value, isNot(before));
  });

  testWidgets('shine and sway leave the hit area as the body', (tester) async {
    await startRun(tester);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 700));
      // The string, under the knot.
      await touch(tester, knot(tester) + const Offset(0, 16));
      expect(find.text('0 of 3'), findsOneWidget, reason: '#$i');
    }
    await touch(tester, bodyCenter(tester));
    expect(find.text('1 of 3'), findsOneWidget);
  });

  testWidgets('shine and sway stop under reduce motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await startRun(tester);
    expect(motion(tester), isNull);
  });

  for (final (name, end) in [
    (
      'the back gesture stops it',
      (WidgetTester t) async {
        await t.binding.handlePopRoute();
        await settle(t);
      },
    ),
    (
      'every balloon is popped',
      (WidgetTester t) async {
        for (var i = 0; i < 3; i++) {
          await touch(t, bodyCenter(t));
        }
      },
    ),
  ]) {
    testWidgets('the screen stays on and system bars hide during a run, and '
        'both come back when $name', (tester) async {
      final modes = <Object?>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'SystemChrome.setEnabledSystemUIMode') {
          modes.add(call.arguments);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await startRun(tester);
      expect(wakelock.on, isTrue);
      expect(modes, ['SystemUiMode.immersiveSticky']);

      await end(tester);
      expect(wakelock.on, isFalse);
      expect(modes.last, 'SystemUiMode.edgeToEdge');
    });
  }

  testWidgets('the run stage fits every tablet size', (tester) async {
    await expectFitsTablets(tester, () => startRun(tester));
  });

  testWidgets('starting and ending on the body pops the balloon', (
    tester,
  ) async {
    await startRun(tester);
    final first = bodyCenter(tester);

    await touch(tester, first);

    expect(find.text('1 of 3'), findsOneWidget);
    expect(runProgress(tester), closeTo(1 / 3, 1e-9));
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
    expect(find.text('1 of 3'), findsOneWidget);
  });

  testWidgets('starting off the body does not pop', (tester) async {
    await startRun(tester);
    await touch(tester, offBody(tester), bodyCenter(tester));
    expect(find.text('0 of 3'), findsOneWidget);
  });

  testWidgets('starting outside the balloon does not pop', (tester) async {
    await startRun(tester);
    final outside = tester.getTopLeft(balloon) - const Offset(10, 10);
    await touch(tester, outside, bodyCenter(tester));
    expect(find.text('0 of 3'), findsOneWidget);
  });

  testWidgets('ending off the body does not pop', (tester) async {
    await startRun(tester);
    await touch(tester, bodyCenter(tester), offBody(tester));
    expect(find.text('0 of 3'), findsOneWidget);
  });

  testWidgets('starting on the knot does not pop', (tester) async {
    await startRun(tester);
    await touch(tester, knot(tester), bodyCenter(tester));
    expect(find.text('0 of 3'), findsOneWidget);
  });

  testWidgets('a cancelled pointer does not pop', (tester) async {
    await startRun(tester);
    final gesture = await tester.startGesture(bodyCenter(tester));
    await gesture.cancel();
    await settle(tester);
    expect(find.text('0 of 3'), findsOneWidget);
  });

  testWidgets('a second finger is ignored while the first is down', (
    tester,
  ) async {
    await startRun(tester);
    final first = await tester.startGesture(bodyCenter(tester), pointer: 1);
    final second = await tester.startGesture(bodyCenter(tester), pointer: 2);
    await second.up();
    await tester.pump();
    expect(find.text('0 of 3'), findsOneWidget);

    await first.up();
    await settle(tester);
    expect(find.text('1 of 3'), findsOneWidget);
  });

  for (final (name, firstDown) in [
    ('off the body', offBody),
    ('on the knot', knot),
    (
      'outside the balloon',
      (WidgetTester t) => t.getTopLeft(balloon) - const Offset(10, 10),
    ),
  ]) {
    testWidgets('a second finger is ignored while the first rests $name', (
      tester,
    ) async {
      await startRun(tester);
      final first = await tester.startGesture(firstDown(tester), pointer: 1);
      await touchWith(tester, bodyCenter(tester), pointer: 2);
      expect(find.text('0 of 3'), findsOneWidget);
      await first.up();
    });
  }

  for (final kind in [PointerDeviceKind.mouse, PointerDeviceKind.stylus]) {
    testWidgets('a ${kind.name} pops the balloon too', (tester) async {
      await startRun(tester);
      await touchWith(tester, bodyCenter(tester), kind: kind);
      expect(find.text('1 of 3'), findsOneWidget);
    });
  }

  testWidgets('a right click does not pop', (tester) async {
    await startRun(tester);
    await touchWith(
      tester,
      bodyCenter(tester),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    expect(find.text('0 of 3'), findsOneWidget);
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
    await settle(tester);
    expect(find.text('Start'), findsOneWidget);
  });

  // Portrait and landscape tablets, in logical pixels.
  for (final size in const [
    Size(1194, 834),
    Size(834, 1194),
    Size(1280, 800),
    Size(800, 1280),
  ]) {
    testWidgets('Exercise and progress pages fit $size', (tester) async {
      await pumpApp(tester, null, size);
      await tester.tap(find.text('Balloon Touch'));
      await settle(tester);
      await tester.tap(find.text('Start'));
      await settle(tester);

      final area = tester.getRect(
        find.ancestor(of: balloon, matching: find.byType(DecoratedBox)).first,
      );
      // The body and knot, not the empty corners of the balloon's square.
      final c = bodyCenter(tester);
      // At the largest pulse, ×1.03.
      final drawn = Rect.fromLTRB(
        c.dx - 61.8,
        c.dy - 77.25,
        c.dx + 61.8,
        c.dy + 88.6,
      );
      expect(area.intersect(drawn), drawn);

      await touch(tester, bodyCenter(tester));
      expect(find.text('Session finished'), findsOneWidget);
    });
  }

  group('pause', () {
    final pauseButton = find.widgetWithText(FilledButton, 'Pause');
    final pausedPanel = find.ancestor(
      of: find.text('Paused'),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            (w.decoration as BoxDecoration?)?.color == HandsColors.panel,
      ),
    );

    Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
      await tester.tap(finder);
      await settle(tester);
    }

    void expectPausedPanel(WidgetTester tester) {
      expect(pausedPanel, findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      expect(balloon, findsNothing);
      expect(tester.widget<FilledButton>(pauseButton).onPressed, isNull);
    }

    testWidgets('Pause swaps the balloon for the Paused panel', (tester) async {
      await startRun(tester);
      await tapAndSettle(tester, pauseButton);
      expectPausedPanel(tester);
      expect(find.text('0 of 3'), findsOneWidget);
    });

    testWidgets('Resume brings back the same balloon at the same spot', (
      tester,
    ) async {
      await startRun(tester);
      await touch(tester, bodyCenter(tester));
      final spot = bodyCenter(tester);

      await tapAndSettle(tester, pauseButton);
      // Touching where the balloon was does nothing while paused, unless it
      // sat where the centred Resume button now is.
      final resume = find.widgetWithText(FilledButton, 'Resume');
      if (!tester.getRect(resume).contains(spot)) await touch(tester, spot);
      await tapAndSettle(tester, find.text('Resume'));

      expect(find.text('Paused'), findsNothing);
      expect(bodyCenter(tester), sameSpot(spot));
      expect(find.text('1 of 3'), findsOneWidget);
      expect(tester.widget<FilledButton>(pauseButton).onPressed, isNotNull);
      await touch(tester, spot);
      expect(find.text('2 of 3'), findsOneWidget);
    });

    testWidgets('a hold from before a pause cannot pop after Resume', (
      tester,
    ) async {
      await startRun(tester);
      final spot = bodyCenter(tester);
      final hold = await tester.startGesture(spot, pointer: 1);
      await tester.pump();

      await touchWith(tester, tester.getCenter(pauseButton), pointer: 2);
      await touchWith(
        tester,
        tester.getCenter(find.text('Resume')),
        pointer: 3,
      );
      await hold.up();
      await settle(tester);

      expect(find.text('0 of 3'), findsOneWidget);
      expect(
        tester
            .widget<BalloonIllustration>(find.byType(BalloonIllustration))
            .pressed,
        isFalse,
      );
      await touch(tester, spot);
      expect(find.text('1 of 3'), findsOneWidget);
    });

    for (final (name, button) in [
      ('Home', find.byTooltip('Home')),
      ('Finish', find.byTooltip('Finish')),
    ]) {
      testWidgets('$name pauses and opens the paused progress page', (
        tester,
      ) async {
        await startRun(tester);
        await touch(tester, bodyCenter(tester));
        await tapAndSettle(tester, button);

        for (final text in [
          '1/3',
          'Session paused',
          'You completed 1 of 3 balloons.',
          'Resume Session',
          'Start New Session',
        ]) {
          expect(find.text(text), findsOneWidget);
        }
        expect(find.text('Session finished'), findsNothing);
        expect(progress(tester), closeTo(1 / 3, 1e-9));
      });
    }

    testWidgets('Resume Session returns to the same balloon and count', (
      tester,
    ) async {
      await startRun(tester);
      await touch(tester, bodyCenter(tester));
      final spot = bodyCenter(tester);
      await tapAndSettle(tester, find.byTooltip('Home'));

      await tapAndSettle(tester, find.text('Resume Session'));

      expect(find.text('Paused'), findsNothing);
      expect(bodyCenter(tester), sameSpot(spot));
      expect(find.text('1 of 3'), findsOneWidget);
      await touch(tester, spot);
      expect(find.text('2 of 3'), findsOneWidget);
    });

    testWidgets('Start New Session from a paused Session returns to the hub', (
      tester,
    ) async {
      await startRun(tester);
      await touch(tester, bodyCenter(tester));
      await tapAndSettle(tester, find.byTooltip('Finish'));

      await tapAndSettle(tester, find.text('Start New Session'));

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Resume Session'), findsNothing);
      await tapAndSettle(tester, find.text('Start'));
      expect(find.text('0 of 3'), findsOneWidget, reason: 'a new Session');
      expect(balloon, findsOneWidget);
    });

    // Lifecycle changes must follow the order the platform reports them in.
    const leave = [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ];
    for (var i = 0; i < leave.length; i++) {
      testWidgets('going ${leave[i].name} pauses the Exercise Run', (
        tester,
      ) async {
        await startRun(tester);
        final spot = bodyCenter(tester);

        for (final state in leave.take(i + 1)) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
        await settle(tester);
        for (final state in [
          ...leave.take(i).toList().reversed,
          AppLifecycleState.resumed,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
        await settle(tester);

        // It stays paused on return until the Patient resumes.
        expectPausedPanel(tester);
        await tapAndSettle(tester, find.text('Resume'));
        expect(bodyCenter(tester), sameSpot(spot));
      });
    }

    testWidgets("the progress page's gear does nothing", (tester) async {
      await startRun(tester);
      await tapAndSettle(tester, find.byTooltip('Home'));
      await tapAndSettle(tester, find.byIcon(Icons.settings));
      expect(find.text('Session paused'), findsOneWidget);
    });
  });

  group('pulse', () {
    /// The balloon's drawn scale: its square is 1.75 × 120 wide unscaled.
    double scale(WidgetTester tester) => tester.getRect(balloon).width / 210;

    /// Samples the scale every 50 ms for [seconds].
    Future<List<double>> sample(
      WidgetTester tester, [
      double seconds = 4,
    ]) async {
      final out = <double>[];
      for (var i = 0; i < seconds * 20; i++) {
        out.add(scale(tester));
        await tester.pump(const Duration(milliseconds: 50));
      }
      return out;
    }

    Future<void> pumpToScale(WidgetTester tester, double target) async {
      for (var i = 0; i < 400 && (scale(tester) - target).abs() > 5e-4; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(scale(tester), closeTo(target, 5e-4));
    }

    testWidgets('scales 0.98 to 1.03 on a 4-second sine', (tester) async {
      await startRun(tester);
      final s = await sample(tester, 6);
      final period = s.sublist(0, 80);
      expect(period.reduce(max), closeTo(1.03, 1e-3));
      expect(period.reduce(min), closeTo(0.98, 1e-3));
      for (var i = 0; i < 40; i++) {
        // A 4-second period, and half a period later it mirrors about 1.005.
        expect(s[i + 80], closeTo(s[i], 1e-6), reason: '#$i');
        expect(s[i + 40], closeTo(2 * 1.005 - s[i], 1e-6), reason: '#$i');
      }
    });

    testWidgets('holds while pressed and resumes on lift', (tester) async {
      await startRun(tester);
      final gesture = await tester.startGesture(bodyCenter(tester));
      await tester.pump();
      final held = scale(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(scale(tester), held);

      await gesture.moveTo(offBody(tester));
      await gesture.up();
      expect((await sample(tester, 1)).toSet(), hasLength(greaterThan(1)));
    });

    testWidgets('pulses again after resuming from the background', (
      tester,
    ) async {
      await startRun(tester);
      // Flutter rejects jumping between paused and resumed, so walk there.
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await settle(tester);
      await tester.tap(find.text('Resume'));
      await tester.pump();
      expect((await sample(tester, 1)).toSet(), hasLength(greaterThan(1)));
    });

    testWidgets('stays at 1.0 with reduce motion on', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await startRun(tester);
      expect(await sample(tester), everyElement(closeTo(1.0, 1e-9)));
    });

    testWidgets('reduce motion switched mid-run stops and restarts it', (
      tester,
    ) async {
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await startRun(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      await tester.pump();
      expect(await sample(tester, 1), everyElement(closeTo(1.0, 1e-9)));

      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      await tester.pump();
      expect((await sample(tester, 1)).toSet(), hasLength(greaterThan(1)));
    });

    testWidgets('the progress illustration stays still', (tester) async {
      await startRun(tester, balloons: 1);
      await touch(tester, bodyCenter(tester));
      final still = find.byType(BalloonIllustration);
      final size = tester.getRect(still);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getRect(still), size);
    });

    // The body's widest point is 0.42 down it, 12 px above its centre.
    Offset rightEdge(WidgetTester tester, double dx) {
      final c = bodyCenter(tester);
      return Offset(c.dx + dx, c.dy - 12 * scale(tester));
    }

    testWidgets('at 1.03 a touch just outside the unscaled body pops', (
      tester,
    ) async {
      await startRun(tester);
      await pumpToScale(tester, 1.03);
      await touch(tester, rightEdge(tester, 61));
      expect(find.text('1 of 3'), findsOneWidget);
    });

    testWidgets('at 0.98 a touch just inside the unscaled body misses', (
      tester,
    ) async {
      await startRun(tester);
      await pumpToScale(tester, 0.98);
      await touch(tester, rightEdge(tester, 59.5));
      expect(find.text('0 of 3'), findsOneWidget);
    });
  });

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
