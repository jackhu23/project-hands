import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'balloon_touch/session.dart';

part 'database.g.dart';

/// How an Exercise Run ended.
enum RunOutcome { completed, stopped }

@DataClassName('PatientRow')
class Patients extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExerciseRunRow')
class ExerciseRuns extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get exercise => text()();
  IntColumn get difficultyLevel => integer()();
  IntColumn get balloonCount => integer()();

  /// The play area in logical pixels; Trial positions are relative to its
  /// top-left.
  RealColumn get areaWidth => real()();
  RealColumn get areaHeight => real()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// Null while the run is running or paused.
  TextColumn get outcome => textEnum<RunOutcome>().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TrialRow')
class Trials extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseRunId => text().references(ExerciseRuns, #id)();
  IntColumn get number => integer()();
  RealColumn get centerX => real()();
  RealColumn get centerY => real()();
  RealColumn get bodyWidth => real()();
  RealColumn get bodyHeight => real()();
  IntColumn get zone => integer()();
  DateTimeColumn get presentedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => textEnum<TrialStatus>()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PauseRow')
class Pauses extends Table {
  TextColumn get exerciseRunId => text().references(ExerciseRuns, #id)();
  IntColumn get number => integer()();
  DateTimeColumn get pausedAt => dateTime()();
  DateTimeColumn get resumedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {exerciseRunId, number};
}

@DataClassName('ActionRow')
class Actions extends Table {
  TextColumn get id => text()();
  TextColumn get trialId => text().references(Trials, #id)();
  DateTimeColumn get touchdownAt => dateTime()();
  DateTimeColumn get liftOffAt => dateTime()();
  TextColumn get outcome => textEnum<ActionOutcome>()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Positions are raw logical pixels from the play area's top-left.
@DataClassName('TouchSampleRow')
class TouchSamples extends Table {
  TextColumn get actionId => text().references(Actions, #id)();
  IntColumn get sequence => integer()();
  DateTimeColumn get time => dateTime()();
  RealColumn get x => real()();
  RealColumn get y => real()();
  RealColumn get pressure => real()();
  TextColumn get kind => textEnum<TouchKind>()();

  @override
  Set<Column> get primaryKey => {actionId, sequence};
}

/// Pops ÷ (Pops + Misses); null when there are neither.
double? accuracy({required int pops, required int misses}) =>
    pops + misses == 0 ? null : pops / (pops + misses);

/// One row of the history page.
typedef HistoryRow = ({
  DateTime startedAt,
  int difficultyLevel,
  Duration duration,
  double? accuracy,
  int popped,
  int balloonCount,
  bool stopped,
});

/// The on-device database (ADR 0002).
@DriftDatabase(
  tables: [
    Patients,
    Sessions,
    ExerciseRuns,
    Trials,
    Pauses,
    Actions,
    TouchSamples,
  ],
)
class HandsDatabase extends _$HandsDatabase {
  HandsDatabase(super.e);

  /// The app's database file, in the app's sandbox.
  HandsDatabase.onDevice() : super(driftDatabase(name: 'hands'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // shortcut: no release has shipped and only synthetic data exists, so
      // version 1's rows are dropped; write real migrations from the first
      // release on.
      for (final table in allTables.toList().reversed) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
  );

  /// Runs at startup: stops any run the app closed on, and returns the
  /// temporary Patient's ID, saving one on first launch.
  Future<String> launch() => transaction(() async {
    await _stopOpenRuns();
    final patient = await select(patients).getSingleOrNull();
    if (patient != null) return patient.id;
    final id = randomId();
    await into(patients).insert(PatientRow(id: id, createdAt: DateTime.now()));
    return id;
  });

  /// Ends each open run at its last recorded activity.
  Future<void> _stopOpenRuns() async {
    final open = await (select(
      exerciseRuns,
    )..where((r) => r.outcome.isNull())).get();
    for (final run in open) {
      // Compared in Dart: SQL max() over these dates drops microseconds.
      final runTrials = await (select(
        trials,
      )..where((t) => t.exerciseRunId.equals(run.id))).get();
      final runActions = await (select(
        actions,
      )..where((a) => a.trialId.isIn(runTrials.map((t) => t.id)))).get();
      final runPauses = await (select(
        pauses,
      )..where((p) => p.exerciseRunId.equals(run.id))).get();
      final endedAt = [
        run.startedAt,
        for (final t in runTrials) ...[t.presentedAt, ?t.completedAt],
        for (final a in runActions) a.liftOffAt,
        for (final p in runPauses) ...[p.pausedAt, ?p.resumedAt],
      ].reduce((a, b) => a.isAfter(b) ? a : b);
      await (update(exerciseRuns)..where((r) => r.id.equals(run.id))).write(
        ExerciseRunsCompanion(
          endedAt: Value(endedAt),
          outcome: const Value(RunOutcome.stopped),
        ),
      );
      // As Session.stop leaves it.
      await (update(trials)..where(
            (t) =>
                t.exerciseRunId.equals(run.id) &
                t.status.equalsValue(TrialStatus.active),
          ))
          .write(const TrialsCompanion(status: Value(TrialStatus.unfinished)));
      await (update(sessions)..where((s) => s.id.equals(run.sessionId))).write(
        SessionsCompanion(endedAt: Value(endedAt)),
      );
    }
  }

  /// Saves a snapshot of [session], its Exercise Run, Trials and pauses,
  /// replacing any earlier snapshot, and the Actions finished since the last
  /// save with their Touch Samples.
  Future<void> saveSession(Session session) async {
    // Taken now, as later calls may run before this transaction does, and
    // put back if it fails so the next save retries them.
    final newActions = [...session.unsavedActions];
    session.unsavedActions.clear();
    try {
      await _save(session, newActions);
    } catch (_) {
      session.unsavedActions.insertAll(0, newActions);
      rethrow;
    }
  }

  Future<void> _save(
    Session session,
    List<Action> newActions,
  ) => transaction(() async {
    final run = session.exerciseRun;
    // Recreates the Patient if "Clear all data" removed it during this launch.
    await into(patients).insert(
      PatientRow(id: session.patientId, createdAt: DateTime.now()),
      mode: InsertMode.insertOrIgnore,
    );
    await into(sessions).insertOnConflictUpdate(
      SessionRow(
        id: session.id,
        patientId: session.patientId,
        startedAt: session.startedAt,
        endedAt: session.endedAt,
      ),
    );
    await into(exerciseRuns).insertOnConflictUpdate(
      ExerciseRunRow(
        id: run.id,
        sessionId: session.id,
        exercise: 'Balloon Touch',
        difficultyLevel: run.difficultyLevel,
        balloonCount: run.balloonCount,
        areaWidth: run.area.width,
        areaHeight: run.area.height,
        startedAt: session.startedAt,
        endedAt: session.endedAt,
        outcome: switch (session.status) {
          SessionStatus.completed => RunOutcome.completed,
          SessionStatus.stopped => RunOutcome.stopped,
          _ => null,
        },
      ),
    );
    await batch((b) {
      b.insertAllOnConflictUpdate(trials, [
        for (final t in run.trials)
          TrialRow(
            id: t.id,
            exerciseRunId: run.id,
            number: t.number,
            centerX: t.center.dx,
            centerY: t.center.dy,
            bodyWidth: t.bodyWidth,
            bodyHeight: t.bodyHeight,
            zone: t.zone,
            presentedAt: t.presentedAt,
            completedAt: t.completedAt,
            status: t.status,
          ),
      ]);
      b.insertAllOnConflictUpdate(pauses, [
        for (final (i, p) in run.pauses.indexed)
          PauseRow(
            exerciseRunId: run.id,
            number: i + 1,
            pausedAt: p.pausedAt,
            resumedAt: p.resumedAt,
          ),
      ]);
      b.insertAllOnConflictUpdate(actions, [
        for (final a in newActions)
          ActionRow(
            id: a.id,
            trialId: a.trial.id,
            touchdownAt: a.touchdownAt,
            liftOffAt: a.liftOffAt,
            outcome: a.outcome,
          ),
      ]);
      b.insertAllOnConflictUpdate(touchSamples, [
        for (final a in newActions)
          for (final s in a.samples)
            TouchSampleRow(
              actionId: a.id,
              sequence: s.sequence,
              time: s.time,
              x: s.position.dx,
              y: s.position.dy,
              pressure: s.pressure,
              kind: s.kind,
            ),
      ]);
    });
  });

  /// The Difficulty Level of the newest Exercise Run, if any.
  Future<int?> lastDifficultyLevel() async {
    final runs = await select(exerciseRuns).get();
    // Compared in Dart, as in history.
    return runs.isEmpty
        ? null
        : runs
              .reduce((a, b) => a.startedAt.isAfter(b.startedAt) ? a : b)
              .difficultyLevel;
  }

  /// Ended Exercise Runs, newest first; optionally for one Patient.
  Future<List<HistoryRow>> history({String? patientId}) async {
    final popped = trials.id.count(
      filter: trials.status.equalsValue(TrialStatus.completed),
    );
    final query =
        select(exerciseRuns).join([
            innerJoin(sessions, sessions.id.equalsExp(exerciseRuns.sessionId)),
            leftOuterJoin(
              trials,
              trials.exerciseRunId.equalsExp(exerciseRuns.id),
            ),
          ])
          ..addColumns([popped])
          ..where(exerciseRuns.outcome.isNotNull())
          ..groupBy([exerciseRuns.id]);
    if (patientId != null) query.where(sessions.patientId.equals(patientId));
    final outcomeCount = actions.id.count();
    final counts = <(String, ActionOutcome), int>{
      for (final row
          in await (select(actions).join([
                  innerJoin(trials, trials.id.equalsExp(actions.trialId)),
                ])
                ..addColumns([outcomeCount])
                ..groupBy([trials.exerciseRunId, actions.outcome]))
              .get())
        (row.readTable(trials).exerciseRunId, row.readTable(actions).outcome):
            row.read(outcomeCount)!,
    };
    return (await query.get()).map((row) {
        final run = row.readTable(exerciseRuns);
        return (
          startedAt: run.startedAt,
          difficultyLevel: run.difficultyLevel,
          accuracy: accuracy(
            pops: counts[(run.id, ActionOutcome.pop)] ?? 0,
            misses: counts[(run.id, ActionOutcome.miss)] ?? 0,
          ),
          // shortcut: includes paused time, until pause times are saved.
          duration: run.endedAt!.difference(run.startedAt),
          popped: row.read(popped)!,
          balloonCount: run.balloonCount,
          stopped: run.outcome == RunOutcome.stopped,
        );
      }).toList()
      // Sorted in Dart, which compares instants; the stored text follows the
      // wall clock, so a daylight-saving change could misorder it in SQL.
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  /// Deletes every row, including the Patient. Debug builds only.
  Future<void> clearAll() => transaction(() async {
    for (final table in allTables.toList().reversed) {
      await delete(table).go();
    }
  });
}
