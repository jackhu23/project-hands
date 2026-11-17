import 'dart:ui';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/balloon_touch/session.dart';
import 'package:hands/database.dart';

HandsDatabase openTestDatabase() {
  final db = HandsDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// A Session with one popped balloon and one still showing.
Session playedSession(String patientId) {
  final session = Session(patientId: patientId, balloonCount: 3);
  session.presentNextTrial(const Size(1000, 800));
  session.completeTrial(session.exerciseRun.activeTrial!);
  session.presentNextTrial(const Size(1000, 800));
  return session;
}

void main() {
  test('launch saves one temporary Patient and reuses it', () async {
    final db = openTestDatabase();

    final first = await db.launch();
    expect(first, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(await db.launch(), first);
    expect(await db.select(db.patients).get(), hasLength(1));
  });

  test('saves the Session, its Exercise Run and its Trials', () async {
    final db = openTestDatabase();
    final session = playedSession(await db.launch());

    await db.saveSession(session);
    session.stop();
    await db.saveSession(session);

    final saved = await db.select(db.sessions).getSingle();
    expect(saved.id, session.id);
    expect(saved.endedAt, session.endedAt);

    final run = await db.select(db.exerciseRuns).getSingle();
    expect(run.sessionId, session.id);
    expect(run.exercise, 'Balloon Touch');
    expect(run.balloonCount, 3);
    expect((run.areaWidth, run.areaHeight), (1000.0, 800.0));
    expect(run.startedAt, session.startedAt);
    expect(run.endedAt, session.endedAt);
    expect(run.outcome, RunOutcome.stopped);

    final trials = await (db.select(
      db.trials,
    )..orderBy([(t) => OrderingTerm(expression: t.number)])).get();
    expect(trials, hasLength(2));
    final popped = session.exerciseRun.trials.first;
    expect(trials[0].exerciseRunId, run.id);
    expect(trials[0].number, 1);
    expect(
      (trials[0].centerX, trials[0].centerY),
      (popped.center.dx, popped.center.dy),
    );
    expect((trials[0].bodyWidth, trials[0].bodyHeight), (120.0, 150.0));
    expect(trials[0].presentedAt, popped.presentedAt);
    expect(trials[0].completedAt, popped.completedAt);
    expect(trials[0].status, TrialStatus.completed);
    expect(trials[1].status, TrialStatus.unfinished);
    expect(trials[1].completedAt, isNull);
  });

  test('saves the Difficulty Level and each Trial\'s Zone', () async {
    final db = openTestDatabase();
    final session = Session(
      patientId: await db.launch(),
      balloonCount: 3,
      difficultyLevel: 3,
    )..presentNextTrial(const Size(1000, 800));

    await db.saveSession(session);

    expect((await db.select(db.exerciseRuns).getSingle()).difficultyLevel, 3);
    expect(
      (await db.select(db.trials).getSingle()).zone,
      session.exerciseRun.trials.single.zone,
    );
  });

  test('a run still open at launch is stopped at its last activity', () async {
    final db = openTestDatabase();
    final session = playedSession(await db.launch());
    await db.saveSession(session);
    final lastActivity = session.exerciseRun.trials.last.presentedAt;

    await db.launch();

    final run = await db.select(db.exerciseRuns).getSingle();
    expect(run.outcome, RunOutcome.stopped);
    expect(run.endedAt, lastActivity);
    expect((await db.select(db.sessions).getSingle()).endedAt, lastActivity);
    // The balloon still showing ends unfinished, as Session.stop leaves it.
    final statuses = (await db.select(db.trials).get()).map((t) => t.status);
    expect(
      statuses,
      unorderedEquals([TrialStatus.completed, TrialStatus.unfinished]),
    );
  });

  test('runs lists ended runs newest first', () async {
    final db = openTestDatabase();
    final patient = await db.launch();
    final older = playedSession(patient)..stop();
    final open = playedSession(patient);
    final newer = Session(patientId: patient, balloonCount: 1)
      ..presentNextTrial(const Size(1000, 800));
    newer.completeTrial(newer.exerciseRun.activeTrial!);
    for (final s in [older, open, newer]) {
      await db.saveSession(s);
    }

    final records = await db.runs();

    expect(records.map((r) => r.run.id), [
      newer.exerciseRun.id,
      older.exerciseRun.id,
    ]);
    final o = records[1];
    expect(o.run.outcome, RunOutcome.stopped);
    expect(o.trials.map((t) => t.number), [1, 2]);
    expect(o.actions, isEmpty);
    expect(o.pauses, isEmpty);
  });

  test('runs carry their Actions and pauses', () async {
    final db = openTestDatabase();
    final session = Session(patientId: await db.launch(), balloonCount: 1)
      ..presentNextTrial(const Size(1000, 800));
    const input = (
      timeStamp: Duration.zero,
      position: Offset.zero,
      pressure: 1.0,
      kind: TouchKind.finger,
    );
    session
      ..touchDown(1, input, onBody: false)
      ..touchUp(1, input, onBody: false)
      ..pause()
      ..resume()
      ..touchDown(1, input, onBody: true)
      ..touchUp(1, input, onBody: true);
    await db.saveSession(session);

    final record = (await db.runs()).single;

    expect(record.actions.map((a) => a.outcome), [
      ActionOutcome.miss,
      ActionOutcome.pop,
    ]);
    expect(record.pauses.single.resumedAt, isNotNull);
  });

  test('Actions from a failed save are kept for the next one', () async {
    final db = HandsDatabase(NativeDatabase.memory());
    final session = Session(patientId: await db.launch(), balloonCount: 1)
      ..presentNextTrial(const Size(1000, 800));
    const input = (
      timeStamp: Duration.zero,
      position: Offset.zero,
      pressure: 1.0,
      kind: TouchKind.finger,
    );
    session
      ..touchDown(1, input, onBody: false)
      ..touchUp(1, input, onBody: false);
    await db.close();

    await expectLater(db.saveSession(session), throwsA(anything));

    expect(session.unsavedActions, hasLength(1));
  });

  test('a version 1 database is rebuilt on upgrade', () async {
    final db = HandsDatabase(
      NativeDatabase.memory(
        setup: (raw) => raw
          ..execute('CREATE TABLE exercise_runs (id TEXT NOT NULL PRIMARY KEY)')
          ..execute('PRAGMA user_version = 1'),
      ),
    );
    addTearDown(db.close);

    await db.saveSession(playedSession(await db.launch())..stop());

    expect(await db.runs(), hasLength(1));
  });

  test('clearAll deletes every row, including the Patient', () async {
    final db = openTestDatabase();
    final session = playedSession(await db.launch())..stop();
    await db.saveSession(session);

    await db.clearAll();

    expect(await db.runs(), isEmpty);
    expect(await db.select(db.patients).get(), isEmpty);
    expect(await db.select(db.trials).get(), isEmpty);
  });
}
