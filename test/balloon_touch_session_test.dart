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

  test('pause holds the active Trial and resume carries on with it', () {
    final session = Session(patientId: 'p', balloonCount: 3);
    session.presentNextTrial(const Size(800, 600));
    final trial = session.exerciseRun.activeTrial!;

    session.pause();
    expect(session.status, SessionStatus.paused);
    session.completeTrial(trial);
    expect(trial.status, TrialStatus.active, reason: 'no pops while paused');

    session.resume();
    expect(session.status, SessionStatus.running);
    expect(session.exerciseRun.activeTrial, same(trial));
  });

  test('stop ends the Session and leaves the active Trial unfinished', () {
    final session = Session(patientId: 'p', balloonCount: 3);
    session.presentNextTrial(const Size(800, 600));
    session.completeTrial(session.exerciseRun.activeTrial!);
    session.presentNextTrial(const Size(800, 600));
    final trial = session.exerciseRun.activeTrial!;
    session.pause();

    session.stop();

    expect(session.status, SessionStatus.stopped);
    expect(session.endedAt, isNotNull);
    expect(trial.status, TrialStatus.unfinished);
    expect(session.exerciseRun.activeTrial, isNull);
    expect(session.exerciseRun.completedTrials, 1);
  });

  test('pause and resume only apply from running and paused', () {
    final session = Session(patientId: 'p', balloonCount: 1);
    session.resume();
    expect(session.status, SessionStatus.running);
    session.presentNextTrial(const Size(800, 600));
    session.completeTrial(session.exerciseRun.activeTrial!);
    session.pause();
    expect(session.status, SessionStatus.completed);
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
