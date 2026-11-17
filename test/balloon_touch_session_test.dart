import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/session.dart';

void main() {
  test('every balloon fits inside the area at the largest pulse', () {
    for (final (area, level) in [
      for (final level in [1, 2, 3, 4])
        for (final area in const [
          Size(1100, 600),
          Size(700, 1000),
          Size(400, 400),
          // Just over the minimum: 2 × 85.8 wide and 2 × 111.75 tall.
          Size(172, 224),
        ])
          (area, level),
    ]) {
      final session = Session(
        patientId: 'p',
        balloonCount: 30,
        difficultyLevel: level,
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
          reason: '$area level $level #$i',
        );
        session.completeTrial(trial);
      }
      expect(session.status, SessionStatus.completed);
    }
  });

  test('balloons land at different spots across the area at Level 4', () {
    final session = Session(
      patientId: 'p',
      balloonCount: 30,
      difficultyLevel: 4,
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

  test('Zones are nested ellipses that scale with the area', () {
    for (final area in const [Size(1200, 800), Size(800, 1200)]) {
      final c = area.center(Offset.zero);
      Offset along(double fraction, {bool vertical = false}) => vertical
          ? c + Offset(0, area.height / 2 * fraction)
          : c + Offset(area.width / 2 * fraction, 0);
      expect(zoneOf(c, area), 1);
      for (final vertical in [false, true]) {
        for (final (i, span) in zoneEllipseSpans.indexed) {
          expect(zoneOf(along(span - 0.01, vertical: vertical), area), i + 1);
          expect(zoneOf(along(span + 0.01, vertical: vertical), area), i + 2);
        }
      }
      expect(zoneOf(Offset.zero, area), 4, reason: 'corner');
    }
  });

  test('at Level 1 every balloon centre is in Zone 1 and Trials say so', () {
    for (final area in const [Size(1194, 834), Size(834, 1194)]) {
      final session = Session(
        patientId: 'p',
        balloonCount: 30,
        random: Random(3),
      );
      expect(session.exerciseRun.difficultyLevel, 1, reason: 'default');
      for (var i = 0; i < 30; i++) {
        session.presentNextTrial(area);
        final trial = session.exerciseRun.activeTrial!;
        expect(zoneOf(trial.center, area), 1, reason: '$area #$i');
        expect(trial.zone, 1);
        session.completeTrial(trial);
      }
    }
  });

  test('at Levels 2 to 4 about 70% land in the outermost Zone with room up '
      'to N, and the rest inside it by area', () {
    for (final area in const [
      Size(1194, 834),
      Size(834, 1194),
      // Phones, where the insets leave Zone 4 no room.
      Size(800, 360),
      Size(360, 800),
      // Phones where Zone 4 is only a sliver, which took thousands to
      // billions of draws per balloon.
      Size(844, 390),
      Size(851, 393),
      Size(817, 393),
      Size(915, 412),
    ]) {
      // Usable area of each Zone: grid points inside the edge insets.
      final rect = usableArea(area)!;
      final usable = List.filled(5, 0);
      for (var x = rect.left; x <= rect.right; x += 2) {
        for (var y = rect.top; y <= rect.bottom; y += 2) {
          usable[zoneOf(Offset(x, y), area)]++;
        }
      }
      final total = usable.reduce((a, b) => a + b);
      final roomiest = usable.lastIndexWhere((n) => n / total >= minZoneRoom);
      for (final level in [2, 3, 4]) {
        const draws = 2000;
        final session = Session(
          patientId: 'p',
          balloonCount: draws,
          difficultyLevel: level,
          random: Random(level),
        );
        final counts = List.filled(5, 0);
        for (var i = 0; i < draws; i++) {
          session.presentNextTrial(area);
          final trial = session.exerciseRun.activeTrial!;
          counts[trial.zone]++;
          session.completeTrial(trial);
        }
        final reason = '$area level $level $counts';
        // Four standard deviations of a share p over n draws.
        double tolerance(double p, int n) => 4 * sqrt(p * (1 - p) / n);

        final own = min(level, roomiest);
        expect(
          counts[own] / draws,
          closeTo(ownZoneShare, tolerance(ownZoneShare, draws)),
          reason: reason,
        );
        for (var zone = own + 1; zone <= 4; zone++) {
          expect(counts[zone], 0, reason: reason);
        }
        final inner = usable.sublist(1, own).reduce((a, b) => a + b);
        final innerDraws = draws - counts[own];
        for (var zone = 1; zone < own; zone++) {
          final share = usable[zone] / inner;
          expect(
            counts[zone] / innerDraws,
            closeTo(share, tolerance(share, innerDraws)),
            reason: '$reason zone $zone',
          );
        }
      }
    }
  });

  test('each Trial reports the Zone its centre is in', () {
    const area = Size(1194, 834);
    final session = Session(
      patientId: 'p',
      balloonCount: 30,
      difficultyLevel: 4,
      random: Random(5),
    );
    final zones = <int>{};
    for (var i = 0; i < 30; i++) {
      session.presentNextTrial(area);
      final trial = session.exerciseRun.activeTrial!;
      expect(trial.zone, zoneOf(trial.center, area));
      zones.add(trial.zone);
      session.completeTrial(trial);
    }
    expect(zones.length, greaterThan(1));
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

  test('pause and stop finish touches still down as Misses or Overlapping '
      'Touches', () {
    TouchInput at(int ms) => (
      timeStamp: Duration(milliseconds: ms),
      position: Offset.zero,
      pressure: 1.0,
      kind: TouchKind.finger,
    );
    for (final end in [(Session s) => s.pause(), (Session s) => s.stop()]) {
      final session = Session(patientId: 'p', balloonCount: 3)
        ..presentNextTrial(const Size(800, 600));
      final trial = session.exerciseRun.activeTrial!;
      session
        ..touchDown(1, at(0), onBody: true)
        ..touchDown(2, at(5), onBody: false)
        ..touchMove(1, at(10));

      end(session);

      expect(trial.actions.map((a) => a.outcome), [
        ActionOutcome.miss,
        ActionOutcome.overlappingTouch,
      ]);
      expect(session.unsavedActions, hasLength(2));
      expect(trial.actions.first.samples, hasLength(2));
      expect(session.pressingBalloon, isFalse);
    }
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
    final a = Session(patientId: 'p', balloonCount: 1);
    final b = Session(patientId: 'p', balloonCount: 1);
    expect(a.id, isNot(b.id));
    expect(a.id, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(a.patientId, 'p');
    expect(a.status, SessionStatus.running);
  });
}
