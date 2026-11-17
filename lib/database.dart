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
  DateTimeColumn get presentedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => textEnum<TrialStatus>()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row of the history page.
typedef HistoryRow = ({
  DateTime startedAt,
  Duration duration,
  int popped,
  int balloonCount,
  bool stopped,
});

/// The on-device database (ADR 0002).
@DriftDatabase(tables: [Patients, Sessions, ExerciseRuns, Trials])
class HandsDatabase extends _$HandsDatabase {
  HandsDatabase(super.e);

  /// The app's database file, in the app's sandbox.
  HandsDatabase.onDevice() : super(driftDatabase(name: 'hands'));

  @override
  int get schemaVersion => 1;

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
      final last = trials.completedAt.max();
      final lastShown = trials.presentedAt.max();
      final row =
          await (selectOnly(trials)
                ..addColumns([last, lastShown])
                ..where(trials.exerciseRunId.equals(run.id)))
              .getSingle();
      final endedAt = [
        run.startedAt,
        ?row.read(last),
        ?row.read(lastShown),
      ].reduce((a, b) => a.isAfter(b) ? a : b);
      await (update(exerciseRuns)..where((r) => r.id.equals(run.id))).write(
        ExerciseRunsCompanion(
          endedAt: Value(endedAt),
          outcome: const Value(RunOutcome.stopped),
        ),
      );
      await (update(sessions)..where((s) => s.id.equals(run.sessionId))).write(
        SessionsCompanion(endedAt: Value(endedAt)),
      );
    }
  }

  /// Saves a snapshot of [session], its Exercise Run and its Trials,
  /// replacing any earlier snapshot.
  Future<void> saveSession(Session session) => transaction(() async {
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
            presentedAt: t.presentedAt,
            completedAt: t.completedAt,
            status: t.status,
          ),
      ]);
    });
  });

  /// Ended Exercise Runs, newest first.
  Future<List<HistoryRow>> history() async {
    final popped = trials.id.count(
      filter: trials.status.equalsValue(TrialStatus.completed),
    );
    final query =
        select(exerciseRuns).join([
            leftOuterJoin(
              trials,
              trials.exerciseRunId.equalsExp(exerciseRuns.id),
            ),
          ])
          ..addColumns([popped])
          ..where(exerciseRuns.outcome.isNotNull())
          ..groupBy([exerciseRuns.id])
          ..orderBy([OrderingTerm.desc(exerciseRuns.startedAt)]);
    return (await query.get()).map((row) {
      final run = row.readTable(exerciseRuns);
      return (
        startedAt: run.startedAt,
        // shortcut: includes paused time, until pause times are saved.
        duration: run.endedAt!.difference(run.startedAt),
        popped: row.read(popped)!,
        balloonCount: run.balloonCount,
        stopped: run.outcome == RunOutcome.stopped,
      );
    }).toList();
  }

  /// Deletes every row, including the Patient. Debug builds only.
  Future<void> clearAll() => transaction(() async {
    for (final table in <TableInfo>[trials, exerciseRuns, sessions, patients]) {
      await delete(table).go();
    }
  });
}
