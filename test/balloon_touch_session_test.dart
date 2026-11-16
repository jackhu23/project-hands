import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/session.dart';

void main() {
  test('every balloon fits inside the area at the largest pulse', () {
    for (final area in const [
      Size(1100, 600),
      Size(700, 1000),
      Size(400, 400),
      // Just over the minimum: 2 × 85.8 wide and 2 × 111.75 tall.
      Size(172, 224),
    ]) {
      final session = Session(
        patientId: 'p',
        balloonCount: 30,
        random: Random(7),
      );
      for (var i = 0; i < 30; i++) {
        session.presentNextTrial(area);
        final trial = session.exerciseRun.activeTrial!;
        const knot = balloonBodyWidth * 0.085;
        final reach = Rect.fromCenter(
          center: trial.center,
          width: trial.bodyWidth * maxPulseScale,
          height: (trial.bodyHeight + knot * 2) * maxPulseScale,
        ).inflate(edgeMargin);
        expect(
          (Offset.zero & area).intersect(reach),
          reach,
          reason: '$area #$i',
        );
        session.completeTrial(trial);
      }
      expect(session.status, SessionStatus.completed);
    }
  });

  test('balloons land at different spots across the area', () {
    final session = Session(
      patientId: 'p',
      balloonCount: 30,
      random: Random(1),
    );
    final xs = <double>[];
    for (var i = 0; i < 30; i++) {
      session.presentNextTrial(const Size(1000, 600));
      xs.add(session.exerciseRun.activeTrial!.center.dx);
      session.completeTrial(session.exerciseRun.activeTrial!);
    }
    expect(xs.reduce(min), lessThan(300));
    expect(xs.reduce(max), greaterThan(700));
  });

  test('no balloon while the area is too small or one is showing', () {
    final session = Session(patientId: 'p', balloonCount: 3);
    session.presentNextTrial(const Size(171, 600));
    expect(session.exerciseRun.trials, isEmpty);

    session.presentNextTrial(const Size(800, 600));
    session.presentNextTrial(const Size(800, 600));
    expect(session.exerciseRun.trials, hasLength(1));
    expect(session.exerciseRun.activeTrial!.number, 1);
  });

  test('a Session has random IDs and starts running', () {
    final a = Session(patientId: temporaryPatientId, balloonCount: 1);
    final b = Session(patientId: temporaryPatientId, balloonCount: 1);
    expect(a.id, isNot(b.id));
    expect(a.id, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(a.patientId, temporaryPatientId);
    expect(a.status, SessionStatus.running);
  });
}
