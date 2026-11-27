import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/session.dart';
import 'package:hands/database.dart';

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

/// Starts a run of [balloons] at [level] from the home screen.
Future<void> startRun(
  WidgetTester tester, {
  int balloons = 3,
  int level = 1,
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tapAndSettle(tester, find.text('Balloon Touch'));
  for (var i = 1; i < balloons; i++) {
    await tester.tap(find.byTooltip('More balloons'));
  }
  await tester.tap(find.bySemanticsLabel('Difficulty Level $level'));
  await tapAndSettle(tester, find.text('Start'));
}

final balloon = find.bySemanticsLabel('Balloon');

Offset bodyCenter(WidgetTester tester) => tester.getCenter(balloon);

/// Inside the balloon's square but off the body.
Offset offBody(WidgetTester tester) =>
    tester.getTopLeft(balloon) + const Offset(4, 4);

/// The play area the balloons are placed in.
Rect playArea(WidgetTester tester) => tester.getRect(
  find.ancestor(of: balloon, matching: find.byType(DecoratedBox)).first,
);

Future<void> touch(WidgetTester tester, Offset down, [Offset? up]) async {
  final gesture = await tester.startGesture(down);
  if (up != null) await gesture.moveTo(up);
  await gesture.up();
  await settle(tester);
}

Matcher near(Offset spot) => isA<Offset>().having(
  (o) => (o - spot).distance,
  'distance',
  lessThan(1e-6),
);

Future<List<ActionRow>> actionsOf(HandsDatabase db) =>
    db.select(db.actions).get();

Future<List<TouchSampleRow>> samplesOf(HandsDatabase db, String actionId) =>
    (db.select(db.touchSamples)
          ..where((s) => s.actionId.equals(actionId))
          ..orderBy([(s) => OrderingTerm(expression: s.sequence)]))
        .get();

Future<List<ActionOutcome>> outcomes(HandsDatabase db) async =>
    (await actionsOf(db)).map((a) => a.outcome).toList();

void main() {
  testWidgets('a pop records one Pop with a Touch Sample per pointer event', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await startRun(tester);
    final area = playArea(tester);
    final down = bodyCenter(tester);
    const slide = Offset(10, 5);

    final gesture = await tester.startGesture(down);
    await gesture.moveBy(slide);
    await gesture.up();
    await settle(tester);

    expect(find.text('1 of 3'), findsOneWidget);
    final action = (await actionsOf(db)).single;
    expect(action.outcome, ActionOutcome.pop);
    final trial = await (db.select(
      db.trials,
    )..where((t) => t.number.equals(1))).getSingle();
    expect(action.trialId, trial.id);

    final samples = await samplesOf(db, action.id);
    expect(samples.map((s) => s.sequence), [0, 1, 2]);
    expect(samples.map((s) => Offset(s.x, s.y)), [
      near(down - area.topLeft),
      near(down + slide - area.topLeft),
      near(down + slide - area.topLeft),
    ]);
    expect(samples.map((s) => s.kind), everyElement(TouchKind.finger));
    expect(samples.first.pressure, 1.0);
    expect(samples.first.time, action.touchdownAt);
    expect(samples.last.time, action.liftOffAt);
  });

  testWidgets('a tap off the balloon and a slide off it each record a Miss', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await startRun(tester);

    await touch(tester, tester.getTopLeft(balloon) - const Offset(10, 10));
    await touch(tester, bodyCenter(tester), offBody(tester));
    expect(find.text('0 of 3'), findsOneWidget);
    // Popping ends the Trial, which flushes its Actions.
    await touch(tester, bodyCenter(tester));

    final actions = await actionsOf(db);
    expect(
      actions.map((a) => a.outcome),
      unorderedEquals([
        ActionOutcome.miss,
        ActionOutcome.miss,
        ActionOutcome.pop,
      ]),
    );
    expect(actions.map((a) => a.trialId).toSet(), hasLength(1));
    final sampleCounts = [
      for (final a in actions) (a.outcome, (await samplesOf(db, a.id)).length),
    ];
    expect(
      sampleCounts,
      unorderedEquals([
        (ActionOutcome.miss, 2),
        (ActionOutcome.miss, 3),
        (ActionOutcome.pop, 2),
      ]),
    );
  });

  testWidgets('a second finger records an Overlapping Touch and never pops', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await startRun(tester);

    final first = await tester.startGesture(offBody(tester), pointer: 1);
    final second = await tester.startGesture(bodyCenter(tester), pointer: 2);
    await first.up();
    // Ends on the body after the first finger has lifted.
    await second.up();
    await settle(tester);
    expect(find.text('0 of 3'), findsOneWidget);
    await touch(tester, bodyCenter(tester));

    expect(
      await outcomes(db),
      unorderedEquals([
        ActionOutcome.miss,
        ActionOutcome.overlappingTouch,
        ActionOutcome.pop,
      ]),
    );
  });

  testWidgets('a touch still down when the last balloon pops is recorded', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await startRun(tester, balloons: 1);

    final first = await tester.startGesture(bodyCenter(tester), pointer: 1);
    final palm = await tester.startGesture(offBody(tester), pointer: 2);
    await first.up();
    await settle(tester);

    expect(find.text('Session finished'), findsOneWidget);
    expect(
      await outcomes(db),
      unorderedEquals([ActionOutcome.pop, ActionOutcome.overlappingTouch]),
    );
    await palm.up();
  });

  testWidgets('a Miss is saved when the run pauses', (tester) async {
    final db = await pumpApp(tester);
    await startRun(tester);

    await touch(tester, tester.getTopLeft(balloon) - const Offset(10, 10));
    await tapAndSettle(tester, find.text('Pause'));

    expect(await outcomes(db), [ActionOutcome.miss]);
  });

  testWidgets('a slide still down when the run pauses is saved as a Miss', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await startRun(tester);

    final slide = await tester.startGesture(bodyCenter(tester));
    await slide.moveBy(const Offset(5, 5));
    await tapAndSettle(tester, find.text('Pause'));
    await slide.up();

    expect(await outcomes(db), [ActionOutcome.miss]);
  });

  for (final (device, kind) in [
    (PointerDeviceKind.stylus, TouchKind.stylus),
    (PointerDeviceKind.invertedStylus, TouchKind.stylus),
    (PointerDeviceKind.mouse, TouchKind.mouse),
  ]) {
    testWidgets('a ${device.name} records ${kind.name} Touch Samples', (
      tester,
    ) async {
      final db = await pumpApp(tester);
      await startRun(tester);

      final gesture = await tester.startGesture(
        bodyCenter(tester),
        kind: device,
      );
      await gesture.up();
      await settle(tester);

      final action = (await actionsOf(db)).single;
      expect(
        (await samplesOf(db, action.id)).map((s) => s.kind),
        everyElement(kind),
      );
    });
  }

  testWidgets('a touch during the Pop burst records no Action', (tester) async {
    final db = await pumpApp(tester);
    await startRun(tester);
    final spot = bodyCenter(tester);
    await tester.tapAt(spot);
    await tester.pump();
    await tester.tapAt(spot);
    await settle(tester);

    expect(await outcomes(db), [ActionOutcome.pop]);
  });

  testWidgets('controls, touches while paused and cancels record no Action', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await startRun(tester);
    final corner = playArea(tester).topLeft + const Offset(20, 20);

    await tapAndSettle(tester, find.text('0 of 3'));
    await tapAndSettle(tester, find.text('Pause'));
    await touch(tester, corner);
    await tapAndSettle(tester, find.text('Resume'));
    final cancelled = await tester.startGesture(bodyCenter(tester));
    await cancelled.cancel();
    await settle(tester);
    await touch(tester, bodyCenter(tester));

    expect(await outcomes(db), [ActionOutcome.pop]);
  });

  testWidgets('each pause and resume time is saved on the Exercise Run', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await startRun(tester);

    await tapAndSettle(tester, find.text('Pause'));
    await tapAndSettle(tester, find.text('Resume'));
    await tapAndSettle(tester, find.byTooltip('Home'));

    final run = await db.select(db.exerciseRuns).getSingle();
    final pauses = await (db.select(
      db.pauses,
    )..orderBy([(p) => OrderingTerm(expression: p.number)])).get();
    expect(pauses, hasLength(2));
    expect(pauses.map((p) => p.exerciseRunId), everyElement(run.id));
    expect(pauses[0].resumedAt!.isBefore(pauses[0].pausedAt), isFalse);
    expect(pauses[1].pausedAt.isBefore(pauses[0].resumedAt!), isFalse);
    expect(pauses[1].resumedAt, isNull);
  });

  testWidgets('history rows show Difficulty Level and Accuracy', (
    tester,
  ) async {
    await pumpApp(tester);
    await startRun(tester, balloons: 1, level: 2);
    await touch(tester, tester.getTopLeft(balloon) - const Offset(10, 10));
    await touch(tester, bodyCenter(tester));

    await tapAndSettle(tester, find.text('View history'));

    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Level 2'),
      ),
      findsOneWidget,
    );
    expect(find.text('Accuracy 50%'), findsOneWidget);
  });
}
