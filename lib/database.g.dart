// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients
    with TableInfo<$PatientsTable, PatientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class PatientRow extends DataClass implements Insertable<PatientRow> {
  final String id;
  final DateTime createdAt;
  const PatientRow({required this.id, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(id: Value(id), createdAt: Value(createdAt));
  }

  factory PatientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PatientRow copyWith({String? id, DateTime? createdAt}) =>
      PatientRow(id: id ?? this.id, createdAt: createdAt ?? this.createdAt);
  PatientRow copyWithCompanion(PatientsCompanion data) {
    return PatientRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt);
}

class PatientsCompanion extends UpdateCompanion<PatientRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<PatientRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, patientId, startedAt, endedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  const SessionRow({
    required this.id,
    required this.patientId,
    required this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => SessionRow(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, patientId, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String patientId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       startedAt = Value(startedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseRunsTable extends ExerciseRuns
    with TableInfo<$ExerciseRunsTable, ExerciseRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _exerciseMeta = const VerificationMeta(
    'exercise',
  );
  @override
  late final GeneratedColumn<String> exercise = GeneratedColumn<String>(
    'exercise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyLevelMeta = const VerificationMeta(
    'difficultyLevel',
  );
  @override
  late final GeneratedColumn<int> difficultyLevel = GeneratedColumn<int>(
    'difficulty_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balloonCountMeta = const VerificationMeta(
    'balloonCount',
  );
  @override
  late final GeneratedColumn<int> balloonCount = GeneratedColumn<int>(
    'balloon_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaWidthMeta = const VerificationMeta(
    'areaWidth',
  );
  @override
  late final GeneratedColumn<double> areaWidth = GeneratedColumn<double>(
    'area_width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaHeightMeta = const VerificationMeta(
    'areaHeight',
  );
  @override
  late final GeneratedColumn<double> areaHeight = GeneratedColumn<double>(
    'area_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RunOutcome?, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RunOutcome?>($ExerciseRunsTable.$converteroutcomen);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exercise,
    difficultyLevel,
    balloonCount,
    areaWidth,
    areaHeight,
    startedAt,
    endedAt,
    outcome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise')) {
      context.handle(
        _exerciseMeta,
        exercise.isAcceptableOrUnknown(data['exercise']!, _exerciseMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseMeta);
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
        _difficultyLevelMeta,
        difficultyLevel.isAcceptableOrUnknown(
          data['difficulty_level']!,
          _difficultyLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_difficultyLevelMeta);
    }
    if (data.containsKey('balloon_count')) {
      context.handle(
        _balloonCountMeta,
        balloonCount.isAcceptableOrUnknown(
          data['balloon_count']!,
          _balloonCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balloonCountMeta);
    }
    if (data.containsKey('area_width')) {
      context.handle(
        _areaWidthMeta,
        areaWidth.isAcceptableOrUnknown(data['area_width']!, _areaWidthMeta),
      );
    } else if (isInserting) {
      context.missing(_areaWidthMeta);
    }
    if (data.containsKey('area_height')) {
      context.handle(
        _areaHeightMeta,
        areaHeight.isAcceptableOrUnknown(data['area_height']!, _areaHeightMeta),
      );
    } else if (isInserting) {
      context.missing(_areaHeightMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exercise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise'],
      )!,
      difficultyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_level'],
      )!,
      balloonCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balloon_count'],
      )!,
      areaWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_width'],
      )!,
      areaHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_height'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      outcome: $ExerciseRunsTable.$converteroutcomen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        ),
      ),
    );
  }

  @override
  $ExerciseRunsTable createAlias(String alias) {
    return $ExerciseRunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RunOutcome, String, String> $converteroutcome =
      const EnumNameConverter<RunOutcome>(RunOutcome.values);
  static JsonTypeConverter2<RunOutcome?, String?, String?> $converteroutcomen =
      JsonTypeConverter2.asNullable($converteroutcome);
}

class ExerciseRunRow extends DataClass implements Insertable<ExerciseRunRow> {
  final String id;
  final String sessionId;
  final String exercise;
  final int difficultyLevel;
  final int balloonCount;

  /// The play area in logical pixels; Trial positions are relative to its
  /// top-left.
  final double areaWidth;
  final double areaHeight;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Null while the run is running or paused.
  final RunOutcome? outcome;
  const ExerciseRunRow({
    required this.id,
    required this.sessionId,
    required this.exercise,
    required this.difficultyLevel,
    required this.balloonCount,
    required this.areaWidth,
    required this.areaHeight,
    required this.startedAt,
    this.endedAt,
    this.outcome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise'] = Variable<String>(exercise);
    map['difficulty_level'] = Variable<int>(difficultyLevel);
    map['balloon_count'] = Variable<int>(balloonCount);
    map['area_width'] = Variable<double>(areaWidth);
    map['area_height'] = Variable<double>(areaHeight);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(
        $ExerciseRunsTable.$converteroutcomen.toSql(outcome),
      );
    }
    return map;
  }

  ExerciseRunsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseRunsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exercise: Value(exercise),
      difficultyLevel: Value(difficultyLevel),
      balloonCount: Value(balloonCount),
      areaWidth: Value(areaWidth),
      areaHeight: Value(areaHeight),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
    );
  }

  factory ExerciseRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRunRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exercise: serializer.fromJson<String>(json['exercise']),
      difficultyLevel: serializer.fromJson<int>(json['difficultyLevel']),
      balloonCount: serializer.fromJson<int>(json['balloonCount']),
      areaWidth: serializer.fromJson<double>(json['areaWidth']),
      areaHeight: serializer.fromJson<double>(json['areaHeight']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      outcome: $ExerciseRunsTable.$converteroutcomen.fromJson(
        serializer.fromJson<String?>(json['outcome']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exercise': serializer.toJson<String>(exercise),
      'difficultyLevel': serializer.toJson<int>(difficultyLevel),
      'balloonCount': serializer.toJson<int>(balloonCount),
      'areaWidth': serializer.toJson<double>(areaWidth),
      'areaHeight': serializer.toJson<double>(areaHeight),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'outcome': serializer.toJson<String?>(
        $ExerciseRunsTable.$converteroutcomen.toJson(outcome),
      ),
    };
  }

  ExerciseRunRow copyWith({
    String? id,
    String? sessionId,
    String? exercise,
    int? difficultyLevel,
    int? balloonCount,
    double? areaWidth,
    double? areaHeight,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<RunOutcome?> outcome = const Value.absent(),
  }) => ExerciseRunRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exercise: exercise ?? this.exercise,
    difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    balloonCount: balloonCount ?? this.balloonCount,
    areaWidth: areaWidth ?? this.areaWidth,
    areaHeight: areaHeight ?? this.areaHeight,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    outcome: outcome.present ? outcome.value : this.outcome,
  );
  ExerciseRunRow copyWithCompanion(ExerciseRunsCompanion data) {
    return ExerciseRunRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exercise: data.exercise.present ? data.exercise.value : this.exercise,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      balloonCount: data.balloonCount.present
          ? data.balloonCount.value
          : this.balloonCount,
      areaWidth: data.areaWidth.present ? data.areaWidth.value : this.areaWidth,
      areaHeight: data.areaHeight.present
          ? data.areaHeight.value
          : this.areaHeight,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRunRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exercise: $exercise, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('balloonCount: $balloonCount, ')
          ..write('areaWidth: $areaWidth, ')
          ..write('areaHeight: $areaHeight, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('outcome: $outcome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exercise,
    difficultyLevel,
    balloonCount,
    areaWidth,
    areaHeight,
    startedAt,
    endedAt,
    outcome,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRunRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exercise == this.exercise &&
          other.difficultyLevel == this.difficultyLevel &&
          other.balloonCount == this.balloonCount &&
          other.areaWidth == this.areaWidth &&
          other.areaHeight == this.areaHeight &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.outcome == this.outcome);
}

class ExerciseRunsCompanion extends UpdateCompanion<ExerciseRunRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exercise;
  final Value<int> difficultyLevel;
  final Value<int> balloonCount;
  final Value<double> areaWidth;
  final Value<double> areaHeight;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<RunOutcome?> outcome;
  final Value<int> rowid;
  const ExerciseRunsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exercise = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.balloonCount = const Value.absent(),
    this.areaWidth = const Value.absent(),
    this.areaHeight = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseRunsCompanion.insert({
    required String id,
    required String sessionId,
    required String exercise,
    required int difficultyLevel,
    required int balloonCount,
    required double areaWidth,
    required double areaHeight,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exercise = Value(exercise),
       difficultyLevel = Value(difficultyLevel),
       balloonCount = Value(balloonCount),
       areaWidth = Value(areaWidth),
       areaHeight = Value(areaHeight),
       startedAt = Value(startedAt);
  static Insertable<ExerciseRunRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exercise,
    Expression<int>? difficultyLevel,
    Expression<int>? balloonCount,
    Expression<double>? areaWidth,
    Expression<double>? areaHeight,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? outcome,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exercise != null) 'exercise': exercise,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (balloonCount != null) 'balloon_count': balloonCount,
      if (areaWidth != null) 'area_width': areaWidth,
      if (areaHeight != null) 'area_height': areaHeight,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (outcome != null) 'outcome': outcome,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exercise,
    Value<int>? difficultyLevel,
    Value<int>? balloonCount,
    Value<double>? areaWidth,
    Value<double>? areaHeight,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<RunOutcome?>? outcome,
    Value<int>? rowid,
  }) {
    return ExerciseRunsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exercise: exercise ?? this.exercise,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      balloonCount: balloonCount ?? this.balloonCount,
      areaWidth: areaWidth ?? this.areaWidth,
      areaHeight: areaHeight ?? this.areaHeight,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      outcome: outcome ?? this.outcome,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exercise.present) {
      map['exercise'] = Variable<String>(exercise.value);
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<int>(difficultyLevel.value);
    }
    if (balloonCount.present) {
      map['balloon_count'] = Variable<int>(balloonCount.value);
    }
    if (areaWidth.present) {
      map['area_width'] = Variable<double>(areaWidth.value);
    }
    if (areaHeight.present) {
      map['area_height'] = Variable<double>(areaHeight.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $ExerciseRunsTable.$converteroutcomen.toSql(outcome.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRunsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exercise: $exercise, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('balloonCount: $balloonCount, ')
          ..write('areaWidth: $areaWidth, ')
          ..write('areaHeight: $areaHeight, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('outcome: $outcome, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrialsTable extends Trials with TableInfo<$TrialsTable, TrialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseRunIdMeta = const VerificationMeta(
    'exerciseRunId',
  );
  @override
  late final GeneratedColumn<String> exerciseRunId = GeneratedColumn<String>(
    'exercise_run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_runs (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _centerXMeta = const VerificationMeta(
    'centerX',
  );
  @override
  late final GeneratedColumn<double> centerX = GeneratedColumn<double>(
    'center_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _centerYMeta = const VerificationMeta(
    'centerY',
  );
  @override
  late final GeneratedColumn<double> centerY = GeneratedColumn<double>(
    'center_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyWidthMeta = const VerificationMeta(
    'bodyWidth',
  );
  @override
  late final GeneratedColumn<double> bodyWidth = GeneratedColumn<double>(
    'body_width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyHeightMeta = const VerificationMeta(
    'bodyHeight',
  );
  @override
  late final GeneratedColumn<double> bodyHeight = GeneratedColumn<double>(
    'body_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<int> zone = GeneratedColumn<int>(
    'zone',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presentedAtMeta = const VerificationMeta(
    'presentedAt',
  );
  @override
  late final GeneratedColumn<DateTime> presentedAt = GeneratedColumn<DateTime>(
    'presented_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrialStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TrialStatus>($TrialsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseRunId,
    number,
    centerX,
    centerY,
    bodyWidth,
    bodyHeight,
    zone,
    presentedAt,
    completedAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trials';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_run_id')) {
      context.handle(
        _exerciseRunIdMeta,
        exerciseRunId.isAcceptableOrUnknown(
          data['exercise_run_id']!,
          _exerciseRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseRunIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('center_x')) {
      context.handle(
        _centerXMeta,
        centerX.isAcceptableOrUnknown(data['center_x']!, _centerXMeta),
      );
    } else if (isInserting) {
      context.missing(_centerXMeta);
    }
    if (data.containsKey('center_y')) {
      context.handle(
        _centerYMeta,
        centerY.isAcceptableOrUnknown(data['center_y']!, _centerYMeta),
      );
    } else if (isInserting) {
      context.missing(_centerYMeta);
    }
    if (data.containsKey('body_width')) {
      context.handle(
        _bodyWidthMeta,
        bodyWidth.isAcceptableOrUnknown(data['body_width']!, _bodyWidthMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyWidthMeta);
    }
    if (data.containsKey('body_height')) {
      context.handle(
        _bodyHeightMeta,
        bodyHeight.isAcceptableOrUnknown(data['body_height']!, _bodyHeightMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyHeightMeta);
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneMeta);
    }
    if (data.containsKey('presented_at')) {
      context.handle(
        _presentedAtMeta,
        presentedAt.isAcceptableOrUnknown(
          data['presented_at']!,
          _presentedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_presentedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrialRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_run_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      centerX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}center_x'],
      )!,
      centerY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}center_y'],
      )!,
      bodyWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_width'],
      )!,
      bodyHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_height'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone'],
      )!,
      presentedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}presented_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      status: $TrialsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $TrialsTable createAlias(String alias) {
    return $TrialsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TrialStatus, String, String> $converterstatus =
      const EnumNameConverter<TrialStatus>(TrialStatus.values);
}

class TrialRow extends DataClass implements Insertable<TrialRow> {
  final String id;
  final String exerciseRunId;
  final int number;
  final double centerX;
  final double centerY;
  final double bodyWidth;
  final double bodyHeight;
  final int zone;
  final DateTime presentedAt;
  final DateTime? completedAt;
  final TrialStatus status;
  const TrialRow({
    required this.id,
    required this.exerciseRunId,
    required this.number,
    required this.centerX,
    required this.centerY,
    required this.bodyWidth,
    required this.bodyHeight,
    required this.zone,
    required this.presentedAt,
    this.completedAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_run_id'] = Variable<String>(exerciseRunId);
    map['number'] = Variable<int>(number);
    map['center_x'] = Variable<double>(centerX);
    map['center_y'] = Variable<double>(centerY);
    map['body_width'] = Variable<double>(bodyWidth);
    map['body_height'] = Variable<double>(bodyHeight);
    map['zone'] = Variable<int>(zone);
    map['presented_at'] = Variable<DateTime>(presentedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    {
      map['status'] = Variable<String>(
        $TrialsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  TrialsCompanion toCompanion(bool nullToAbsent) {
    return TrialsCompanion(
      id: Value(id),
      exerciseRunId: Value(exerciseRunId),
      number: Value(number),
      centerX: Value(centerX),
      centerY: Value(centerY),
      bodyWidth: Value(bodyWidth),
      bodyHeight: Value(bodyHeight),
      zone: Value(zone),
      presentedAt: Value(presentedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
    );
  }

  factory TrialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrialRow(
      id: serializer.fromJson<String>(json['id']),
      exerciseRunId: serializer.fromJson<String>(json['exerciseRunId']),
      number: serializer.fromJson<int>(json['number']),
      centerX: serializer.fromJson<double>(json['centerX']),
      centerY: serializer.fromJson<double>(json['centerY']),
      bodyWidth: serializer.fromJson<double>(json['bodyWidth']),
      bodyHeight: serializer.fromJson<double>(json['bodyHeight']),
      zone: serializer.fromJson<int>(json['zone']),
      presentedAt: serializer.fromJson<DateTime>(json['presentedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      status: $TrialsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseRunId': serializer.toJson<String>(exerciseRunId),
      'number': serializer.toJson<int>(number),
      'centerX': serializer.toJson<double>(centerX),
      'centerY': serializer.toJson<double>(centerY),
      'bodyWidth': serializer.toJson<double>(bodyWidth),
      'bodyHeight': serializer.toJson<double>(bodyHeight),
      'zone': serializer.toJson<int>(zone),
      'presentedAt': serializer.toJson<DateTime>(presentedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'status': serializer.toJson<String>(
        $TrialsTable.$converterstatus.toJson(status),
      ),
    };
  }

  TrialRow copyWith({
    String? id,
    String? exerciseRunId,
    int? number,
    double? centerX,
    double? centerY,
    double? bodyWidth,
    double? bodyHeight,
    int? zone,
    DateTime? presentedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    TrialStatus? status,
  }) => TrialRow(
    id: id ?? this.id,
    exerciseRunId: exerciseRunId ?? this.exerciseRunId,
    number: number ?? this.number,
    centerX: centerX ?? this.centerX,
    centerY: centerY ?? this.centerY,
    bodyWidth: bodyWidth ?? this.bodyWidth,
    bodyHeight: bodyHeight ?? this.bodyHeight,
    zone: zone ?? this.zone,
    presentedAt: presentedAt ?? this.presentedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    status: status ?? this.status,
  );
  TrialRow copyWithCompanion(TrialsCompanion data) {
    return TrialRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseRunId: data.exerciseRunId.present
          ? data.exerciseRunId.value
          : this.exerciseRunId,
      number: data.number.present ? data.number.value : this.number,
      centerX: data.centerX.present ? data.centerX.value : this.centerX,
      centerY: data.centerY.present ? data.centerY.value : this.centerY,
      bodyWidth: data.bodyWidth.present ? data.bodyWidth.value : this.bodyWidth,
      bodyHeight: data.bodyHeight.present
          ? data.bodyHeight.value
          : this.bodyHeight,
      zone: data.zone.present ? data.zone.value : this.zone,
      presentedAt: data.presentedAt.present
          ? data.presentedAt.value
          : this.presentedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrialRow(')
          ..write('id: $id, ')
          ..write('exerciseRunId: $exerciseRunId, ')
          ..write('number: $number, ')
          ..write('centerX: $centerX, ')
          ..write('centerY: $centerY, ')
          ..write('bodyWidth: $bodyWidth, ')
          ..write('bodyHeight: $bodyHeight, ')
          ..write('zone: $zone, ')
          ..write('presentedAt: $presentedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseRunId,
    number,
    centerX,
    centerY,
    bodyWidth,
    bodyHeight,
    zone,
    presentedAt,
    completedAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrialRow &&
          other.id == this.id &&
          other.exerciseRunId == this.exerciseRunId &&
          other.number == this.number &&
          other.centerX == this.centerX &&
          other.centerY == this.centerY &&
          other.bodyWidth == this.bodyWidth &&
          other.bodyHeight == this.bodyHeight &&
          other.zone == this.zone &&
          other.presentedAt == this.presentedAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status);
}

class TrialsCompanion extends UpdateCompanion<TrialRow> {
  final Value<String> id;
  final Value<String> exerciseRunId;
  final Value<int> number;
  final Value<double> centerX;
  final Value<double> centerY;
  final Value<double> bodyWidth;
  final Value<double> bodyHeight;
  final Value<int> zone;
  final Value<DateTime> presentedAt;
  final Value<DateTime?> completedAt;
  final Value<TrialStatus> status;
  final Value<int> rowid;
  const TrialsCompanion({
    this.id = const Value.absent(),
    this.exerciseRunId = const Value.absent(),
    this.number = const Value.absent(),
    this.centerX = const Value.absent(),
    this.centerY = const Value.absent(),
    this.bodyWidth = const Value.absent(),
    this.bodyHeight = const Value.absent(),
    this.zone = const Value.absent(),
    this.presentedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrialsCompanion.insert({
    required String id,
    required String exerciseRunId,
    required int number,
    required double centerX,
    required double centerY,
    required double bodyWidth,
    required double bodyHeight,
    required int zone,
    required DateTime presentedAt,
    this.completedAt = const Value.absent(),
    required TrialStatus status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseRunId = Value(exerciseRunId),
       number = Value(number),
       centerX = Value(centerX),
       centerY = Value(centerY),
       bodyWidth = Value(bodyWidth),
       bodyHeight = Value(bodyHeight),
       zone = Value(zone),
       presentedAt = Value(presentedAt),
       status = Value(status);
  static Insertable<TrialRow> custom({
    Expression<String>? id,
    Expression<String>? exerciseRunId,
    Expression<int>? number,
    Expression<double>? centerX,
    Expression<double>? centerY,
    Expression<double>? bodyWidth,
    Expression<double>? bodyHeight,
    Expression<int>? zone,
    Expression<DateTime>? presentedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseRunId != null) 'exercise_run_id': exerciseRunId,
      if (number != null) 'number': number,
      if (centerX != null) 'center_x': centerX,
      if (centerY != null) 'center_y': centerY,
      if (bodyWidth != null) 'body_width': bodyWidth,
      if (bodyHeight != null) 'body_height': bodyHeight,
      if (zone != null) 'zone': zone,
      if (presentedAt != null) 'presented_at': presentedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrialsCompanion copyWith({
    Value<String>? id,
    Value<String>? exerciseRunId,
    Value<int>? number,
    Value<double>? centerX,
    Value<double>? centerY,
    Value<double>? bodyWidth,
    Value<double>? bodyHeight,
    Value<int>? zone,
    Value<DateTime>? presentedAt,
    Value<DateTime?>? completedAt,
    Value<TrialStatus>? status,
    Value<int>? rowid,
  }) {
    return TrialsCompanion(
      id: id ?? this.id,
      exerciseRunId: exerciseRunId ?? this.exerciseRunId,
      number: number ?? this.number,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      bodyWidth: bodyWidth ?? this.bodyWidth,
      bodyHeight: bodyHeight ?? this.bodyHeight,
      zone: zone ?? this.zone,
      presentedAt: presentedAt ?? this.presentedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseRunId.present) {
      map['exercise_run_id'] = Variable<String>(exerciseRunId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (centerX.present) {
      map['center_x'] = Variable<double>(centerX.value);
    }
    if (centerY.present) {
      map['center_y'] = Variable<double>(centerY.value);
    }
    if (bodyWidth.present) {
      map['body_width'] = Variable<double>(bodyWidth.value);
    }
    if (bodyHeight.present) {
      map['body_height'] = Variable<double>(bodyHeight.value);
    }
    if (zone.present) {
      map['zone'] = Variable<int>(zone.value);
    }
    if (presentedAt.present) {
      map['presented_at'] = Variable<DateTime>(presentedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TrialsTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrialsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseRunId: $exerciseRunId, ')
          ..write('number: $number, ')
          ..write('centerX: $centerX, ')
          ..write('centerY: $centerY, ')
          ..write('bodyWidth: $bodyWidth, ')
          ..write('bodyHeight: $bodyHeight, ')
          ..write('zone: $zone, ')
          ..write('presentedAt: $presentedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PausesTable extends Pauses with TableInfo<$PausesTable, PauseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PausesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseRunIdMeta = const VerificationMeta(
    'exerciseRunId',
  );
  @override
  late final GeneratedColumn<String> exerciseRunId = GeneratedColumn<String>(
    'exercise_run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_runs (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resumedAtMeta = const VerificationMeta(
    'resumedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resumedAt = GeneratedColumn<DateTime>(
    'resumed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseRunId,
    number,
    pausedAt,
    resumedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pauses';
  @override
  VerificationContext validateIntegrity(
    Insertable<PauseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_run_id')) {
      context.handle(
        _exerciseRunIdMeta,
        exerciseRunId.isAcceptableOrUnknown(
          data['exercise_run_id']!,
          _exerciseRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseRunIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pausedAtMeta);
    }
    if (data.containsKey('resumed_at')) {
      context.handle(
        _resumedAtMeta,
        resumedAt.isAcceptableOrUnknown(data['resumed_at']!, _resumedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseRunId, number};
  @override
  PauseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PauseRow(
      exerciseRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_run_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      )!,
      resumedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resumed_at'],
      ),
    );
  }

  @override
  $PausesTable createAlias(String alias) {
    return $PausesTable(attachedDatabase, alias);
  }
}

class PauseRow extends DataClass implements Insertable<PauseRow> {
  final String exerciseRunId;
  final int number;
  final DateTime pausedAt;
  final DateTime? resumedAt;
  const PauseRow({
    required this.exerciseRunId,
    required this.number,
    required this.pausedAt,
    this.resumedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_run_id'] = Variable<String>(exerciseRunId);
    map['number'] = Variable<int>(number);
    map['paused_at'] = Variable<DateTime>(pausedAt);
    if (!nullToAbsent || resumedAt != null) {
      map['resumed_at'] = Variable<DateTime>(resumedAt);
    }
    return map;
  }

  PausesCompanion toCompanion(bool nullToAbsent) {
    return PausesCompanion(
      exerciseRunId: Value(exerciseRunId),
      number: Value(number),
      pausedAt: Value(pausedAt),
      resumedAt: resumedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resumedAt),
    );
  }

  factory PauseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PauseRow(
      exerciseRunId: serializer.fromJson<String>(json['exerciseRunId']),
      number: serializer.fromJson<int>(json['number']),
      pausedAt: serializer.fromJson<DateTime>(json['pausedAt']),
      resumedAt: serializer.fromJson<DateTime?>(json['resumedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseRunId': serializer.toJson<String>(exerciseRunId),
      'number': serializer.toJson<int>(number),
      'pausedAt': serializer.toJson<DateTime>(pausedAt),
      'resumedAt': serializer.toJson<DateTime?>(resumedAt),
    };
  }

  PauseRow copyWith({
    String? exerciseRunId,
    int? number,
    DateTime? pausedAt,
    Value<DateTime?> resumedAt = const Value.absent(),
  }) => PauseRow(
    exerciseRunId: exerciseRunId ?? this.exerciseRunId,
    number: number ?? this.number,
    pausedAt: pausedAt ?? this.pausedAt,
    resumedAt: resumedAt.present ? resumedAt.value : this.resumedAt,
  );
  PauseRow copyWithCompanion(PausesCompanion data) {
    return PauseRow(
      exerciseRunId: data.exerciseRunId.present
          ? data.exerciseRunId.value
          : this.exerciseRunId,
      number: data.number.present ? data.number.value : this.number,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      resumedAt: data.resumedAt.present ? data.resumedAt.value : this.resumedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PauseRow(')
          ..write('exerciseRunId: $exerciseRunId, ')
          ..write('number: $number, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('resumedAt: $resumedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseRunId, number, pausedAt, resumedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PauseRow &&
          other.exerciseRunId == this.exerciseRunId &&
          other.number == this.number &&
          other.pausedAt == this.pausedAt &&
          other.resumedAt == this.resumedAt);
}

class PausesCompanion extends UpdateCompanion<PauseRow> {
  final Value<String> exerciseRunId;
  final Value<int> number;
  final Value<DateTime> pausedAt;
  final Value<DateTime?> resumedAt;
  final Value<int> rowid;
  const PausesCompanion({
    this.exerciseRunId = const Value.absent(),
    this.number = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.resumedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PausesCompanion.insert({
    required String exerciseRunId,
    required int number,
    required DateTime pausedAt,
    this.resumedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseRunId = Value(exerciseRunId),
       number = Value(number),
       pausedAt = Value(pausedAt);
  static Insertable<PauseRow> custom({
    Expression<String>? exerciseRunId,
    Expression<int>? number,
    Expression<DateTime>? pausedAt,
    Expression<DateTime>? resumedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseRunId != null) 'exercise_run_id': exerciseRunId,
      if (number != null) 'number': number,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (resumedAt != null) 'resumed_at': resumedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PausesCompanion copyWith({
    Value<String>? exerciseRunId,
    Value<int>? number,
    Value<DateTime>? pausedAt,
    Value<DateTime?>? resumedAt,
    Value<int>? rowid,
  }) {
    return PausesCompanion(
      exerciseRunId: exerciseRunId ?? this.exerciseRunId,
      number: number ?? this.number,
      pausedAt: pausedAt ?? this.pausedAt,
      resumedAt: resumedAt ?? this.resumedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseRunId.present) {
      map['exercise_run_id'] = Variable<String>(exerciseRunId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (resumedAt.present) {
      map['resumed_at'] = Variable<DateTime>(resumedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PausesCompanion(')
          ..write('exerciseRunId: $exerciseRunId, ')
          ..write('number: $number, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('resumedAt: $resumedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActionsTable extends Actions with TableInfo<$ActionsTable, ActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trialIdMeta = const VerificationMeta(
    'trialId',
  );
  @override
  late final GeneratedColumn<String> trialId = GeneratedColumn<String>(
    'trial_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trials (id)',
    ),
  );
  static const VerificationMeta _touchdownAtMeta = const VerificationMeta(
    'touchdownAt',
  );
  @override
  late final GeneratedColumn<DateTime> touchdownAt = GeneratedColumn<DateTime>(
    'touchdown_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _liftOffAtMeta = const VerificationMeta(
    'liftOffAt',
  );
  @override
  late final GeneratedColumn<DateTime> liftOffAt = GeneratedColumn<DateTime>(
    'lift_off_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActionOutcome, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActionOutcome>($ActionsTable.$converteroutcome);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trialId,
    touchdownAt,
    liftOffAt,
    outcome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trial_id')) {
      context.handle(
        _trialIdMeta,
        trialId.isAcceptableOrUnknown(data['trial_id']!, _trialIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trialIdMeta);
    }
    if (data.containsKey('touchdown_at')) {
      context.handle(
        _touchdownAtMeta,
        touchdownAt.isAcceptableOrUnknown(
          data['touchdown_at']!,
          _touchdownAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_touchdownAtMeta);
    }
    if (data.containsKey('lift_off_at')) {
      context.handle(
        _liftOffAtMeta,
        liftOffAt.isAcceptableOrUnknown(data['lift_off_at']!, _liftOffAtMeta),
      );
    } else if (isInserting) {
      context.missing(_liftOffAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trial_id'],
      )!,
      touchdownAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}touchdown_at'],
      )!,
      liftOffAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lift_off_at'],
      )!,
      outcome: $ActionsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
    );
  }

  @override
  $ActionsTable createAlias(String alias) {
    return $ActionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActionOutcome, String, String> $converteroutcome =
      const EnumNameConverter<ActionOutcome>(ActionOutcome.values);
}

class ActionRow extends DataClass implements Insertable<ActionRow> {
  final String id;
  final String trialId;
  final DateTime touchdownAt;
  final DateTime liftOffAt;
  final ActionOutcome outcome;
  const ActionRow({
    required this.id,
    required this.trialId,
    required this.touchdownAt,
    required this.liftOffAt,
    required this.outcome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trial_id'] = Variable<String>(trialId);
    map['touchdown_at'] = Variable<DateTime>(touchdownAt);
    map['lift_off_at'] = Variable<DateTime>(liftOffAt);
    {
      map['outcome'] = Variable<String>(
        $ActionsTable.$converteroutcome.toSql(outcome),
      );
    }
    return map;
  }

  ActionsCompanion toCompanion(bool nullToAbsent) {
    return ActionsCompanion(
      id: Value(id),
      trialId: Value(trialId),
      touchdownAt: Value(touchdownAt),
      liftOffAt: Value(liftOffAt),
      outcome: Value(outcome),
    );
  }

  factory ActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionRow(
      id: serializer.fromJson<String>(json['id']),
      trialId: serializer.fromJson<String>(json['trialId']),
      touchdownAt: serializer.fromJson<DateTime>(json['touchdownAt']),
      liftOffAt: serializer.fromJson<DateTime>(json['liftOffAt']),
      outcome: $ActionsTable.$converteroutcome.fromJson(
        serializer.fromJson<String>(json['outcome']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trialId': serializer.toJson<String>(trialId),
      'touchdownAt': serializer.toJson<DateTime>(touchdownAt),
      'liftOffAt': serializer.toJson<DateTime>(liftOffAt),
      'outcome': serializer.toJson<String>(
        $ActionsTable.$converteroutcome.toJson(outcome),
      ),
    };
  }

  ActionRow copyWith({
    String? id,
    String? trialId,
    DateTime? touchdownAt,
    DateTime? liftOffAt,
    ActionOutcome? outcome,
  }) => ActionRow(
    id: id ?? this.id,
    trialId: trialId ?? this.trialId,
    touchdownAt: touchdownAt ?? this.touchdownAt,
    liftOffAt: liftOffAt ?? this.liftOffAt,
    outcome: outcome ?? this.outcome,
  );
  ActionRow copyWithCompanion(ActionsCompanion data) {
    return ActionRow(
      id: data.id.present ? data.id.value : this.id,
      trialId: data.trialId.present ? data.trialId.value : this.trialId,
      touchdownAt: data.touchdownAt.present
          ? data.touchdownAt.value
          : this.touchdownAt,
      liftOffAt: data.liftOffAt.present ? data.liftOffAt.value : this.liftOffAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionRow(')
          ..write('id: $id, ')
          ..write('trialId: $trialId, ')
          ..write('touchdownAt: $touchdownAt, ')
          ..write('liftOffAt: $liftOffAt, ')
          ..write('outcome: $outcome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trialId, touchdownAt, liftOffAt, outcome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionRow &&
          other.id == this.id &&
          other.trialId == this.trialId &&
          other.touchdownAt == this.touchdownAt &&
          other.liftOffAt == this.liftOffAt &&
          other.outcome == this.outcome);
}

class ActionsCompanion extends UpdateCompanion<ActionRow> {
  final Value<String> id;
  final Value<String> trialId;
  final Value<DateTime> touchdownAt;
  final Value<DateTime> liftOffAt;
  final Value<ActionOutcome> outcome;
  final Value<int> rowid;
  const ActionsCompanion({
    this.id = const Value.absent(),
    this.trialId = const Value.absent(),
    this.touchdownAt = const Value.absent(),
    this.liftOffAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionsCompanion.insert({
    required String id,
    required String trialId,
    required DateTime touchdownAt,
    required DateTime liftOffAt,
    required ActionOutcome outcome,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trialId = Value(trialId),
       touchdownAt = Value(touchdownAt),
       liftOffAt = Value(liftOffAt),
       outcome = Value(outcome);
  static Insertable<ActionRow> custom({
    Expression<String>? id,
    Expression<String>? trialId,
    Expression<DateTime>? touchdownAt,
    Expression<DateTime>? liftOffAt,
    Expression<String>? outcome,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trialId != null) 'trial_id': trialId,
      if (touchdownAt != null) 'touchdown_at': touchdownAt,
      if (liftOffAt != null) 'lift_off_at': liftOffAt,
      if (outcome != null) 'outcome': outcome,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionsCompanion copyWith({
    Value<String>? id,
    Value<String>? trialId,
    Value<DateTime>? touchdownAt,
    Value<DateTime>? liftOffAt,
    Value<ActionOutcome>? outcome,
    Value<int>? rowid,
  }) {
    return ActionsCompanion(
      id: id ?? this.id,
      trialId: trialId ?? this.trialId,
      touchdownAt: touchdownAt ?? this.touchdownAt,
      liftOffAt: liftOffAt ?? this.liftOffAt,
      outcome: outcome ?? this.outcome,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trialId.present) {
      map['trial_id'] = Variable<String>(trialId.value);
    }
    if (touchdownAt.present) {
      map['touchdown_at'] = Variable<DateTime>(touchdownAt.value);
    }
    if (liftOffAt.present) {
      map['lift_off_at'] = Variable<DateTime>(liftOffAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $ActionsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionsCompanion(')
          ..write('id: $id, ')
          ..write('trialId: $trialId, ')
          ..write('touchdownAt: $touchdownAt, ')
          ..write('liftOffAt: $liftOffAt, ')
          ..write('outcome: $outcome, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TouchSamplesTable extends TouchSamples
    with TableInfo<$TouchSamplesTable, TouchSampleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TouchSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES actions (id)',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pressureMeta = const VerificationMeta(
    'pressure',
  );
  @override
  late final GeneratedColumn<double> pressure = GeneratedColumn<double>(
    'pressure',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TouchKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TouchKind>($TouchSamplesTable.$converterkind);
  @override
  List<GeneratedColumn> get $columns => [
    actionId,
    sequence,
    time,
    x,
    y,
    pressure,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'touch_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<TouchSampleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actionIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('pressure')) {
      context.handle(
        _pressureMeta,
        pressure.isAcceptableOrUnknown(data['pressure']!, _pressureMeta),
      );
    } else if (isInserting) {
      context.missing(_pressureMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {actionId, sequence};
  @override
  TouchSampleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TouchSampleRow(
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      pressure: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pressure'],
      )!,
      kind: $TouchSamplesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
    );
  }

  @override
  $TouchSamplesTable createAlias(String alias) {
    return $TouchSamplesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TouchKind, String, String> $converterkind =
      const EnumNameConverter<TouchKind>(TouchKind.values);
}

class TouchSampleRow extends DataClass implements Insertable<TouchSampleRow> {
  final String actionId;
  final int sequence;
  final DateTime time;
  final double x;
  final double y;
  final double pressure;
  final TouchKind kind;
  const TouchSampleRow({
    required this.actionId,
    required this.sequence,
    required this.time,
    required this.x,
    required this.y,
    required this.pressure,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['action_id'] = Variable<String>(actionId);
    map['sequence'] = Variable<int>(sequence);
    map['time'] = Variable<DateTime>(time);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['pressure'] = Variable<double>(pressure);
    {
      map['kind'] = Variable<String>(
        $TouchSamplesTable.$converterkind.toSql(kind),
      );
    }
    return map;
  }

  TouchSamplesCompanion toCompanion(bool nullToAbsent) {
    return TouchSamplesCompanion(
      actionId: Value(actionId),
      sequence: Value(sequence),
      time: Value(time),
      x: Value(x),
      y: Value(y),
      pressure: Value(pressure),
      kind: Value(kind),
    );
  }

  factory TouchSampleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TouchSampleRow(
      actionId: serializer.fromJson<String>(json['actionId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      time: serializer.fromJson<DateTime>(json['time']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      pressure: serializer.fromJson<double>(json['pressure']),
      kind: $TouchSamplesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'actionId': serializer.toJson<String>(actionId),
      'sequence': serializer.toJson<int>(sequence),
      'time': serializer.toJson<DateTime>(time),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'pressure': serializer.toJson<double>(pressure),
      'kind': serializer.toJson<String>(
        $TouchSamplesTable.$converterkind.toJson(kind),
      ),
    };
  }

  TouchSampleRow copyWith({
    String? actionId,
    int? sequence,
    DateTime? time,
    double? x,
    double? y,
    double? pressure,
    TouchKind? kind,
  }) => TouchSampleRow(
    actionId: actionId ?? this.actionId,
    sequence: sequence ?? this.sequence,
    time: time ?? this.time,
    x: x ?? this.x,
    y: y ?? this.y,
    pressure: pressure ?? this.pressure,
    kind: kind ?? this.kind,
  );
  TouchSampleRow copyWithCompanion(TouchSamplesCompanion data) {
    return TouchSampleRow(
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      time: data.time.present ? data.time.value : this.time,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      pressure: data.pressure.present ? data.pressure.value : this.pressure,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TouchSampleRow(')
          ..write('actionId: $actionId, ')
          ..write('sequence: $sequence, ')
          ..write('time: $time, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('pressure: $pressure, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(actionId, sequence, time, x, y, pressure, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TouchSampleRow &&
          other.actionId == this.actionId &&
          other.sequence == this.sequence &&
          other.time == this.time &&
          other.x == this.x &&
          other.y == this.y &&
          other.pressure == this.pressure &&
          other.kind == this.kind);
}

class TouchSamplesCompanion extends UpdateCompanion<TouchSampleRow> {
  final Value<String> actionId;
  final Value<int> sequence;
  final Value<DateTime> time;
  final Value<double> x;
  final Value<double> y;
  final Value<double> pressure;
  final Value<TouchKind> kind;
  final Value<int> rowid;
  const TouchSamplesCompanion({
    this.actionId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.time = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.pressure = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TouchSamplesCompanion.insert({
    required String actionId,
    required int sequence,
    required DateTime time,
    required double x,
    required double y,
    required double pressure,
    required TouchKind kind,
    this.rowid = const Value.absent(),
  }) : actionId = Value(actionId),
       sequence = Value(sequence),
       time = Value(time),
       x = Value(x),
       y = Value(y),
       pressure = Value(pressure),
       kind = Value(kind);
  static Insertable<TouchSampleRow> custom({
    Expression<String>? actionId,
    Expression<int>? sequence,
    Expression<DateTime>? time,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? pressure,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (actionId != null) 'action_id': actionId,
      if (sequence != null) 'sequence': sequence,
      if (time != null) 'time': time,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (pressure != null) 'pressure': pressure,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TouchSamplesCompanion copyWith({
    Value<String>? actionId,
    Value<int>? sequence,
    Value<DateTime>? time,
    Value<double>? x,
    Value<double>? y,
    Value<double>? pressure,
    Value<TouchKind>? kind,
    Value<int>? rowid,
  }) {
    return TouchSamplesCompanion(
      actionId: actionId ?? this.actionId,
      sequence: sequence ?? this.sequence,
      time: time ?? this.time,
      x: x ?? this.x,
      y: y ?? this.y,
      pressure: pressure ?? this.pressure,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (pressure.present) {
      map['pressure'] = Variable<double>(pressure.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $TouchSamplesTable.$converterkind.toSql(kind.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TouchSamplesCompanion(')
          ..write('actionId: $actionId, ')
          ..write('sequence: $sequence, ')
          ..write('time: $time, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('pressure: $pressure, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HandsDatabase extends GeneratedDatabase {
  _$HandsDatabase(QueryExecutor e) : super(e);
  $HandsDatabaseManager get managers => $HandsDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ExerciseRunsTable exerciseRuns = $ExerciseRunsTable(this);
  late final $TrialsTable trials = $TrialsTable(this);
  late final $PausesTable pauses = $PausesTable(this);
  late final $ActionsTable actions = $ActionsTable(this);
  late final $TouchSamplesTable touchSamples = $TouchSamplesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    sessions,
    exerciseRuns,
    trials,
    pauses,
    actions,
    touchSamples,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PatientsTableReferences
    extends BaseReferences<_$HandsDatabase, $PatientsTable, PatientRow> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<SessionRow>>
  _sessionsRefsTable(_$HandsDatabase db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'patients__id__sessions__patient_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$HandsDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$HandsDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$HandsDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$HandsDatabase,
          $PatientsTable,
          PatientRow,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (PatientRow, $$PatientsTableReferences),
          PatientRow,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$PatientsTableTableManager(_$HandsDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PatientsCompanion(id: id, createdAt: createdAt, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PatientsTable, PatientRow>(table),
                  $$PatientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedDataByColumns<
                      PatientRow,
                      $PatientsTable,
                      SessionRow,
                      $SessionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PatientsTableReferences(db, table, p0).sessionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'patient_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$HandsDatabase,
      $PatientsTable,
      PatientRow,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (PatientRow, $$PatientsTableReferences),
      PatientRow,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String patientId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$HandsDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$HandsDatabase db) =>
      db.patients.createAlias('sessions__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseRunsTable, List<ExerciseRunRow>>
  _exerciseRunsRefsTable(_$HandsDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseRuns,
    aliasName: 'sessions__id__exercise_runs__session_id',
  );

  $$ExerciseRunsTableProcessedTableManager get exerciseRunsRefs {
    final manager = $$ExerciseRunsTableTableManager(
      $_db,
      $_db.exerciseRuns,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$HandsDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseRunsRefs(
    Expression<bool> Function($$ExerciseRunsTableFilterComposer f) f,
  ) {
    final $$ExerciseRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$HandsDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$HandsDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseRunsRefs<T extends Object>(
    Expression<T> Function($$ExerciseRunsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$HandsDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool patientId, bool exerciseRunsRefs})
        > {
  $$SessionsTableTableManager(_$HandsDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                patientId: patientId,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                patientId: patientId,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, SessionRow>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({patientId = false, exerciseRunsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseRunsRefs) db.exerciseRuns,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (patientId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.patientId,
                            referencedTable: $$SessionsTableReferences
                                ._patientIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._patientIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseRunsRefs)
                        await $_getPrefetchedDataByColumns<
                          SessionRow,
                          $SessionsTable,
                          ExerciseRunRow,
                          $ExerciseRunsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._exerciseRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseRunsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$HandsDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool patientId, bool exerciseRunsRefs})
    >;
typedef $$ExerciseRunsTableCreateCompanionBuilder =
    ExerciseRunsCompanion Function({
      required String id,
      required String sessionId,
      required String exercise,
      required int difficultyLevel,
      required int balloonCount,
      required double areaWidth,
      required double areaHeight,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<RunOutcome?> outcome,
      Value<int> rowid,
    });
typedef $$ExerciseRunsTableUpdateCompanionBuilder =
    ExerciseRunsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> exercise,
      Value<int> difficultyLevel,
      Value<int> balloonCount,
      Value<double> areaWidth,
      Value<double> areaHeight,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<RunOutcome?> outcome,
      Value<int> rowid,
    });

final class $$ExerciseRunsTableReferences
    extends
        BaseReferences<_$HandsDatabase, $ExerciseRunsTable, ExerciseRunRow> {
  $$ExerciseRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$HandsDatabase db) =>
      db.sessions.createAlias('exercise_runs__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TrialsTable, List<TrialRow>> _trialsRefsTable(
    _$HandsDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.trials,
    aliasName: 'exercise_runs__id__trials__exercise_run_id',
  );

  $$TrialsTableProcessedTableManager get trialsRefs {
    final manager = $$TrialsTableTableManager(
      $_db,
      $_db.trials,
    ).filter((f) => f.exerciseRunId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trialsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PausesTable, List<PauseRow>> _pausesRefsTable(
    _$HandsDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pauses,
    aliasName: 'exercise_runs__id__pauses__exercise_run_id',
  );

  $$PausesTableProcessedTableManager get pausesRefs {
    final manager = $$PausesTableTableManager(
      $_db,
      $_db.pauses,
    ).filter((f) => f.exerciseRunId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pausesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseRunsTableFilterComposer
    extends Composer<_$HandsDatabase, $ExerciseRunsTable> {
  $$ExerciseRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balloonCount => $composableBuilder(
    column: $table.balloonCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaWidth => $composableBuilder(
    column: $table.areaWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaHeight => $composableBuilder(
    column: $table.areaHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RunOutcome?, RunOutcome, String> get outcome =>
      $composableBuilder(
        column: $table.outcome,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> trialsRefs(
    Expression<bool> Function($$TrialsTableFilterComposer f) f,
  ) {
    final $$TrialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trials,
      getReferencedColumn: (t) => t.exerciseRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrialsTableFilterComposer(
            $db: $db,
            $table: $db.trials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pausesRefs(
    Expression<bool> Function($$PausesTableFilterComposer f) f,
  ) {
    final $$PausesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauses,
      getReferencedColumn: (t) => t.exerciseRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PausesTableFilterComposer(
            $db: $db,
            $table: $db.pauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseRunsTableOrderingComposer
    extends Composer<_$HandsDatabase, $ExerciseRunsTable> {
  $$ExerciseRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balloonCount => $composableBuilder(
    column: $table.balloonCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaWidth => $composableBuilder(
    column: $table.areaWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaHeight => $composableBuilder(
    column: $table.areaHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseRunsTableAnnotationComposer
    extends Composer<_$HandsDatabase, $ExerciseRunsTable> {
  $$ExerciseRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exercise =>
      $composableBuilder(column: $table.exercise, builder: (column) => column);

  GeneratedColumn<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balloonCount => $composableBuilder(
    column: $table.balloonCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaWidth =>
      $composableBuilder(column: $table.areaWidth, builder: (column) => column);

  GeneratedColumn<double> get areaHeight => $composableBuilder(
    column: $table.areaHeight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RunOutcome?, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> trialsRefs<T extends Object>(
    Expression<T> Function($$TrialsTableAnnotationComposer a) f,
  ) {
    final $$TrialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trials,
      getReferencedColumn: (t) => t.exerciseRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrialsTableAnnotationComposer(
            $db: $db,
            $table: $db.trials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pausesRefs<T extends Object>(
    Expression<T> Function($$PausesTableAnnotationComposer a) f,
  ) {
    final $$PausesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauses,
      getReferencedColumn: (t) => t.exerciseRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PausesTableAnnotationComposer(
            $db: $db,
            $table: $db.pauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseRunsTableTableManager
    extends
        RootTableManager<
          _$HandsDatabase,
          $ExerciseRunsTable,
          ExerciseRunRow,
          $$ExerciseRunsTableFilterComposer,
          $$ExerciseRunsTableOrderingComposer,
          $$ExerciseRunsTableAnnotationComposer,
          $$ExerciseRunsTableCreateCompanionBuilder,
          $$ExerciseRunsTableUpdateCompanionBuilder,
          (ExerciseRunRow, $$ExerciseRunsTableReferences),
          ExerciseRunRow,
          PrefetchHooks Function({
            bool sessionId,
            bool trialsRefs,
            bool pausesRefs,
          })
        > {
  $$ExerciseRunsTableTableManager(_$HandsDatabase db, $ExerciseRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exercise = const Value.absent(),
                Value<int> difficultyLevel = const Value.absent(),
                Value<int> balloonCount = const Value.absent(),
                Value<double> areaWidth = const Value.absent(),
                Value<double> areaHeight = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<RunOutcome?> outcome = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseRunsCompanion(
                id: id,
                sessionId: sessionId,
                exercise: exercise,
                difficultyLevel: difficultyLevel,
                balloonCount: balloonCount,
                areaWidth: areaWidth,
                areaHeight: areaHeight,
                startedAt: startedAt,
                endedAt: endedAt,
                outcome: outcome,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String exercise,
                required int difficultyLevel,
                required int balloonCount,
                required double areaWidth,
                required double areaHeight,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<RunOutcome?> outcome = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseRunsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exercise: exercise,
                difficultyLevel: difficultyLevel,
                balloonCount: balloonCount,
                areaWidth: areaWidth,
                areaHeight: areaHeight,
                startedAt: startedAt,
                endedAt: endedAt,
                outcome: outcome,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseRunsTable, ExerciseRunRow>(table),
                  $$ExerciseRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, trialsRefs = false, pausesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trialsRefs) db.trials,
                    if (pausesRefs) db.pauses,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$ExerciseRunsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$ExerciseRunsTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trialsRefs)
                        await $_getPrefetchedDataByColumns<
                          ExerciseRunRow,
                          $ExerciseRunsTable,
                          TrialRow,
                          $TrialsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseRunsTableReferences
                              ._trialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).trialsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_run_id',
                          typedResults: items,
                        ),
                      if (pausesRefs)
                        await $_getPrefetchedDataByColumns<
                          ExerciseRunRow,
                          $ExerciseRunsTable,
                          PauseRow,
                          $PausesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseRunsTableReferences
                              ._pausesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).pausesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_run_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExerciseRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$HandsDatabase,
      $ExerciseRunsTable,
      ExerciseRunRow,
      $$ExerciseRunsTableFilterComposer,
      $$ExerciseRunsTableOrderingComposer,
      $$ExerciseRunsTableAnnotationComposer,
      $$ExerciseRunsTableCreateCompanionBuilder,
      $$ExerciseRunsTableUpdateCompanionBuilder,
      (ExerciseRunRow, $$ExerciseRunsTableReferences),
      ExerciseRunRow,
      PrefetchHooks Function({bool sessionId, bool trialsRefs, bool pausesRefs})
    >;
typedef $$TrialsTableCreateCompanionBuilder = TrialsCompanion Function({
  required String id,
  required String exerciseRunId,
  required int number,
  required double centerX,
  required double centerY,
  required double bodyWidth,
  required double bodyHeight,
  required int zone,
  required DateTime presentedAt,
  Value<DateTime?> completedAt,
  required TrialStatus status,
  Value<int> rowid,
});
typedef $$TrialsTableUpdateCompanionBuilder = TrialsCompanion Function({
  Value<String> id,
  Value<String> exerciseRunId,
  Value<int> number,
  Value<double> centerX,
  Value<double> centerY,
  Value<double> bodyWidth,
  Value<double> bodyHeight,
  Value<int> zone,
  Value<DateTime> presentedAt,
  Value<DateTime?> completedAt,
  Value<TrialStatus> status,
  Value<int> rowid,
});

final class $$TrialsTableReferences
    extends BaseReferences<_$HandsDatabase, $TrialsTable, TrialRow> {
  $$TrialsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseRunsTable _exerciseRunIdTable(_$HandsDatabase db) =>
      db.exerciseRuns.createAlias('trials__exercise_run_id__exercise_runs__id');

  $$ExerciseRunsTableProcessedTableManager get exerciseRunId {
    final $_column = $_itemColumn<String>('exercise_run_id')!;

    final manager = $$ExerciseRunsTableTableManager(
      $_db,
      $_db.exerciseRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActionsTable, List<ActionRow>> _actionsRefsTable(
    _$HandsDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.actions,
    aliasName: 'trials__id__actions__trial_id',
  );

  $$ActionsTableProcessedTableManager get actionsRefs {
    final manager = $$ActionsTableTableManager(
      $_db,
      $_db.actions,
    ).filter((f) => f.trialId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_actionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrialsTableFilterComposer
    extends Composer<_$HandsDatabase, $TrialsTable> {
  $$TrialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get centerX => $composableBuilder(
    column: $table.centerX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get centerY => $composableBuilder(
    column: $table.centerY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyWidth => $composableBuilder(
    column: $table.bodyWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyHeight => $composableBuilder(
    column: $table.bodyHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get presentedAt => $composableBuilder(
    column: $table.presentedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrialStatus, TrialStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ExerciseRunsTableFilterComposer get exerciseRunId {
    final $$ExerciseRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRunId,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> actionsRefs(
    Expression<bool> Function($$ActionsTableFilterComposer f) f,
  ) {
    final $$ActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.trialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableFilterComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrialsTableOrderingComposer
    extends Composer<_$HandsDatabase, $TrialsTable> {
  $$TrialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get centerX => $composableBuilder(
    column: $table.centerX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get centerY => $composableBuilder(
    column: $table.centerY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyWidth => $composableBuilder(
    column: $table.bodyWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyHeight => $composableBuilder(
    column: $table.bodyHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get presentedAt => $composableBuilder(
    column: $table.presentedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseRunsTableOrderingComposer get exerciseRunId {
    final $$ExerciseRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRunId,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrialsTableAnnotationComposer
    extends Composer<_$HandsDatabase, $TrialsTable> {
  $$TrialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<double> get centerX =>
      $composableBuilder(column: $table.centerX, builder: (column) => column);

  GeneratedColumn<double> get centerY =>
      $composableBuilder(column: $table.centerY, builder: (column) => column);

  GeneratedColumn<double> get bodyWidth =>
      $composableBuilder(column: $table.bodyWidth, builder: (column) => column);

  GeneratedColumn<double> get bodyHeight => $composableBuilder(
    column: $table.bodyHeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<DateTime> get presentedAt => $composableBuilder(
    column: $table.presentedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TrialStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ExerciseRunsTableAnnotationComposer get exerciseRunId {
    final $$ExerciseRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRunId,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> actionsRefs<T extends Object>(
    Expression<T> Function($$ActionsTableAnnotationComposer a) f,
  ) {
    final $$ActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.trialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrialsTableTableManager
    extends
        RootTableManager<
          _$HandsDatabase,
          $TrialsTable,
          TrialRow,
          $$TrialsTableFilterComposer,
          $$TrialsTableOrderingComposer,
          $$TrialsTableAnnotationComposer,
          $$TrialsTableCreateCompanionBuilder,
          $$TrialsTableUpdateCompanionBuilder,
          (TrialRow, $$TrialsTableReferences),
          TrialRow,
          PrefetchHooks Function({bool exerciseRunId, bool actionsRefs})
        > {
  $$TrialsTableTableManager(_$HandsDatabase db, $TrialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> exerciseRunId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<double> centerX = const Value.absent(),
                Value<double> centerY = const Value.absent(),
                Value<double> bodyWidth = const Value.absent(),
                Value<double> bodyHeight = const Value.absent(),
                Value<int> zone = const Value.absent(),
                Value<DateTime> presentedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<TrialStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrialsCompanion(
                id: id,
                exerciseRunId: exerciseRunId,
                number: number,
                centerX: centerX,
                centerY: centerY,
                bodyWidth: bodyWidth,
                bodyHeight: bodyHeight,
                zone: zone,
                presentedAt: presentedAt,
                completedAt: completedAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String exerciseRunId,
                required int number,
                required double centerX,
                required double centerY,
                required double bodyWidth,
                required double bodyHeight,
                required int zone,
                required DateTime presentedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                required TrialStatus status,
                Value<int> rowid = const Value.absent(),
              }) => TrialsCompanion.insert(
                id: id,
                exerciseRunId: exerciseRunId,
                number: number,
                centerX: centerX,
                centerY: centerY,
                bodyWidth: bodyWidth,
                bodyHeight: bodyHeight,
                zone: zone,
                presentedAt: presentedAt,
                completedAt: completedAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrialsTable, TrialRow>(table),
                  $$TrialsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exerciseRunId = false, actionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (actionsRefs) db.actions],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (exerciseRunId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseRunId,
                            referencedTable: $$TrialsTableReferences
                                ._exerciseRunIdTable(db),
                            referencedColumn: $$TrialsTableReferences
                                ._exerciseRunIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (actionsRefs)
                        await $_getPrefetchedDataByColumns<
                          TrialRow,
                          $TrialsTable,
                          ActionRow,
                          $ActionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TrialsTableReferences
                              ._actionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrialsTableReferences(
                                db,
                                table,
                                p0,
                              ).actionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'trial_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TrialsTableProcessedTableManager =
    ProcessedTableManager<
      _$HandsDatabase,
      $TrialsTable,
      TrialRow,
      $$TrialsTableFilterComposer,
      $$TrialsTableOrderingComposer,
      $$TrialsTableAnnotationComposer,
      $$TrialsTableCreateCompanionBuilder,
      $$TrialsTableUpdateCompanionBuilder,
      (TrialRow, $$TrialsTableReferences),
      TrialRow,
      PrefetchHooks Function({bool exerciseRunId, bool actionsRefs})
    >;
typedef $$PausesTableCreateCompanionBuilder = PausesCompanion Function({
  required String exerciseRunId,
  required int number,
  required DateTime pausedAt,
  Value<DateTime?> resumedAt,
  Value<int> rowid,
});
typedef $$PausesTableUpdateCompanionBuilder = PausesCompanion Function({
  Value<String> exerciseRunId,
  Value<int> number,
  Value<DateTime> pausedAt,
  Value<DateTime?> resumedAt,
  Value<int> rowid,
});

final class $$PausesTableReferences
    extends BaseReferences<_$HandsDatabase, $PausesTable, PauseRow> {
  $$PausesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseRunsTable _exerciseRunIdTable(_$HandsDatabase db) =>
      db.exerciseRuns.createAlias('pauses__exercise_run_id__exercise_runs__id');

  $$ExerciseRunsTableProcessedTableManager get exerciseRunId {
    final $_column = $_itemColumn<String>('exercise_run_id')!;

    final manager = $$ExerciseRunsTableTableManager(
      $_db,
      $_db.exerciseRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PausesTableFilterComposer
    extends Composer<_$HandsDatabase, $PausesTable> {
  $$PausesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resumedAt => $composableBuilder(
    column: $table.resumedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseRunsTableFilterComposer get exerciseRunId {
    final $$ExerciseRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRunId,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PausesTableOrderingComposer
    extends Composer<_$HandsDatabase, $PausesTable> {
  $$PausesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resumedAt => $composableBuilder(
    column: $table.resumedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseRunsTableOrderingComposer get exerciseRunId {
    final $$ExerciseRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRunId,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PausesTableAnnotationComposer
    extends Composer<_$HandsDatabase, $PausesTable> {
  $$PausesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resumedAt =>
      $composableBuilder(column: $table.resumedAt, builder: (column) => column);

  $$ExerciseRunsTableAnnotationComposer get exerciseRunId {
    final $$ExerciseRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseRunId,
      referencedTable: $db.exerciseRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PausesTableTableManager
    extends
        RootTableManager<
          _$HandsDatabase,
          $PausesTable,
          PauseRow,
          $$PausesTableFilterComposer,
          $$PausesTableOrderingComposer,
          $$PausesTableAnnotationComposer,
          $$PausesTableCreateCompanionBuilder,
          $$PausesTableUpdateCompanionBuilder,
          (PauseRow, $$PausesTableReferences),
          PauseRow,
          PrefetchHooks Function({bool exerciseRunId})
        > {
  $$PausesTableTableManager(_$HandsDatabase db, $PausesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PausesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PausesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PausesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseRunId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<DateTime> pausedAt = const Value.absent(),
                Value<DateTime?> resumedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PausesCompanion(
                exerciseRunId: exerciseRunId,
                number: number,
                pausedAt: pausedAt,
                resumedAt: resumedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseRunId,
                required int number,
                required DateTime pausedAt,
                Value<DateTime?> resumedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PausesCompanion.insert(
                exerciseRunId: exerciseRunId,
                number: number,
                pausedAt: pausedAt,
                resumedAt: resumedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PausesTable, PauseRow>(table),
                  $$PausesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseRunId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseRunId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseRunId,
                        referencedTable: $$PausesTableReferences
                            ._exerciseRunIdTable(db),
                        referencedColumn: $$PausesTableReferences
                            ._exerciseRunIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PausesTableProcessedTableManager =
    ProcessedTableManager<
      _$HandsDatabase,
      $PausesTable,
      PauseRow,
      $$PausesTableFilterComposer,
      $$PausesTableOrderingComposer,
      $$PausesTableAnnotationComposer,
      $$PausesTableCreateCompanionBuilder,
      $$PausesTableUpdateCompanionBuilder,
      (PauseRow, $$PausesTableReferences),
      PauseRow,
      PrefetchHooks Function({bool exerciseRunId})
    >;
typedef $$ActionsTableCreateCompanionBuilder = ActionsCompanion Function({
  required String id,
  required String trialId,
  required DateTime touchdownAt,
  required DateTime liftOffAt,
  required ActionOutcome outcome,
  Value<int> rowid,
});
typedef $$ActionsTableUpdateCompanionBuilder = ActionsCompanion Function({
  Value<String> id,
  Value<String> trialId,
  Value<DateTime> touchdownAt,
  Value<DateTime> liftOffAt,
  Value<ActionOutcome> outcome,
  Value<int> rowid,
});

final class $$ActionsTableReferences
    extends BaseReferences<_$HandsDatabase, $ActionsTable, ActionRow> {
  $$ActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrialsTable _trialIdTable(_$HandsDatabase db) =>
      db.trials.createAlias('actions__trial_id__trials__id');

  $$TrialsTableProcessedTableManager get trialId {
    final $_column = $_itemColumn<String>('trial_id')!;

    final manager = $$TrialsTableTableManager(
      $_db,
      $_db.trials,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trialIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TouchSamplesTable, List<TouchSampleRow>>
  _touchSamplesRefsTable(_$HandsDatabase db) => MultiTypedResultKey.fromTable(
    db.touchSamples,
    aliasName: 'actions__id__touch_samples__action_id',
  );

  $$TouchSamplesTableProcessedTableManager get touchSamplesRefs {
    final manager = $$TouchSamplesTableTableManager(
      $_db,
      $_db.touchSamples,
    ).filter((f) => f.actionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_touchSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActionsTableFilterComposer
    extends Composer<_$HandsDatabase, $ActionsTable> {
  $$ActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get touchdownAt => $composableBuilder(
    column: $table.touchdownAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get liftOffAt => $composableBuilder(
    column: $table.liftOffAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActionOutcome, ActionOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$TrialsTableFilterComposer get trialId {
    final $$TrialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trialId,
      referencedTable: $db.trials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrialsTableFilterComposer(
            $db: $db,
            $table: $db.trials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> touchSamplesRefs(
    Expression<bool> Function($$TouchSamplesTableFilterComposer f) f,
  ) {
    final $$TouchSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.touchSamples,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TouchSamplesTableFilterComposer(
            $db: $db,
            $table: $db.touchSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActionsTableOrderingComposer
    extends Composer<_$HandsDatabase, $ActionsTable> {
  $$ActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get touchdownAt => $composableBuilder(
    column: $table.touchdownAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get liftOffAt => $composableBuilder(
    column: $table.liftOffAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrialsTableOrderingComposer get trialId {
    final $$TrialsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trialId,
      referencedTable: $db.trials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrialsTableOrderingComposer(
            $db: $db,
            $table: $db.trials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActionsTableAnnotationComposer
    extends Composer<_$HandsDatabase, $ActionsTable> {
  $$ActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get touchdownAt => $composableBuilder(
    column: $table.touchdownAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get liftOffAt =>
      $composableBuilder(column: $table.liftOffAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActionOutcome, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  $$TrialsTableAnnotationComposer get trialId {
    final $$TrialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trialId,
      referencedTable: $db.trials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrialsTableAnnotationComposer(
            $db: $db,
            $table: $db.trials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> touchSamplesRefs<T extends Object>(
    Expression<T> Function($$TouchSamplesTableAnnotationComposer a) f,
  ) {
    final $$TouchSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.touchSamples,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TouchSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.touchSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActionsTableTableManager
    extends
        RootTableManager<
          _$HandsDatabase,
          $ActionsTable,
          ActionRow,
          $$ActionsTableFilterComposer,
          $$ActionsTableOrderingComposer,
          $$ActionsTableAnnotationComposer,
          $$ActionsTableCreateCompanionBuilder,
          $$ActionsTableUpdateCompanionBuilder,
          (ActionRow, $$ActionsTableReferences),
          ActionRow,
          PrefetchHooks Function({bool trialId, bool touchSamplesRefs})
        > {
  $$ActionsTableTableManager(_$HandsDatabase db, $ActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trialId = const Value.absent(),
                Value<DateTime> touchdownAt = const Value.absent(),
                Value<DateTime> liftOffAt = const Value.absent(),
                Value<ActionOutcome> outcome = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionsCompanion(
                id: id,
                trialId: trialId,
                touchdownAt: touchdownAt,
                liftOffAt: liftOffAt,
                outcome: outcome,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trialId,
                required DateTime touchdownAt,
                required DateTime liftOffAt,
                required ActionOutcome outcome,
                Value<int> rowid = const Value.absent(),
              }) => ActionsCompanion.insert(
                id: id,
                trialId: trialId,
                touchdownAt: touchdownAt,
                liftOffAt: liftOffAt,
                outcome: outcome,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActionsTable, ActionRow>(table),
                  $$ActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trialId = false, touchSamplesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (touchSamplesRefs) db.touchSamples],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trialId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trialId,
                        referencedTable: $$ActionsTableReferences._trialIdTable(
                          db,
                        ),
                        referencedColumn: $$ActionsTableReferences
                            ._trialIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (touchSamplesRefs)
                    await $_getPrefetchedDataByColumns<
                      ActionRow,
                      $ActionsTable,
                      TouchSampleRow,
                      $TouchSamplesTable
                    >(
                      currentTable: table,
                      referencedTable: $$ActionsTableReferences
                          ._touchSamplesRefsTable(db),
                      managerFromTypedResult: (p0) => $$ActionsTableReferences(
                        db,
                        table,
                        p0,
                      ).touchSamplesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'action_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$HandsDatabase,
      $ActionsTable,
      ActionRow,
      $$ActionsTableFilterComposer,
      $$ActionsTableOrderingComposer,
      $$ActionsTableAnnotationComposer,
      $$ActionsTableCreateCompanionBuilder,
      $$ActionsTableUpdateCompanionBuilder,
      (ActionRow, $$ActionsTableReferences),
      ActionRow,
      PrefetchHooks Function({bool trialId, bool touchSamplesRefs})
    >;
typedef $$TouchSamplesTableCreateCompanionBuilder =
    TouchSamplesCompanion Function({
      required String actionId,
      required int sequence,
      required DateTime time,
      required double x,
      required double y,
      required double pressure,
      required TouchKind kind,
      Value<int> rowid,
    });
typedef $$TouchSamplesTableUpdateCompanionBuilder =
    TouchSamplesCompanion Function({
      Value<String> actionId,
      Value<int> sequence,
      Value<DateTime> time,
      Value<double> x,
      Value<double> y,
      Value<double> pressure,
      Value<TouchKind> kind,
      Value<int> rowid,
    });

final class $$TouchSamplesTableReferences
    extends
        BaseReferences<_$HandsDatabase, $TouchSamplesTable, TouchSampleRow> {
  $$TouchSamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActionsTable _actionIdTable(_$HandsDatabase db) =>
      db.actions.createAlias('touch_samples__action_id__actions__id');

  $$ActionsTableProcessedTableManager get actionId {
    final $_column = $_itemColumn<String>('action_id')!;

    final manager = $$ActionsTableTableManager(
      $_db,
      $_db.actions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TouchSamplesTableFilterComposer
    extends Composer<_$HandsDatabase, $TouchSamplesTable> {
  $$TouchSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TouchKind, TouchKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ActionsTableFilterComposer get actionId {
    final $$ActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableFilterComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TouchSamplesTableOrderingComposer
    extends Composer<_$HandsDatabase, $TouchSamplesTable> {
  $$TouchSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActionsTableOrderingComposer get actionId {
    final $$ActionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableOrderingComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TouchSamplesTableAnnotationComposer
    extends Composer<_$HandsDatabase, $TouchSamplesTable> {
  $$TouchSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get pressure =>
      $composableBuilder(column: $table.pressure, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TouchKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$ActionsTableAnnotationComposer get actionId {
    final $$ActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.actions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.actions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TouchSamplesTableTableManager
    extends
        RootTableManager<
          _$HandsDatabase,
          $TouchSamplesTable,
          TouchSampleRow,
          $$TouchSamplesTableFilterComposer,
          $$TouchSamplesTableOrderingComposer,
          $$TouchSamplesTableAnnotationComposer,
          $$TouchSamplesTableCreateCompanionBuilder,
          $$TouchSamplesTableUpdateCompanionBuilder,
          (TouchSampleRow, $$TouchSamplesTableReferences),
          TouchSampleRow,
          PrefetchHooks Function({bool actionId})
        > {
  $$TouchSamplesTableTableManager(_$HandsDatabase db, $TouchSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TouchSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TouchSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TouchSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> actionId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> pressure = const Value.absent(),
                Value<TouchKind> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TouchSamplesCompanion(
                actionId: actionId,
                sequence: sequence,
                time: time,
                x: x,
                y: y,
                pressure: pressure,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String actionId,
                required int sequence,
                required DateTime time,
                required double x,
                required double y,
                required double pressure,
                required TouchKind kind,
                Value<int> rowid = const Value.absent(),
              }) => TouchSamplesCompanion.insert(
                actionId: actionId,
                sequence: sequence,
                time: time,
                x: x,
                y: y,
                pressure: pressure,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TouchSamplesTable, TouchSampleRow>(table),
                  $$TouchSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({actionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (actionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.actionId,
                        referencedTable: $$TouchSamplesTableReferences
                            ._actionIdTable(db),
                        referencedColumn: $$TouchSamplesTableReferences
                            ._actionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TouchSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$HandsDatabase,
      $TouchSamplesTable,
      TouchSampleRow,
      $$TouchSamplesTableFilterComposer,
      $$TouchSamplesTableOrderingComposer,
      $$TouchSamplesTableAnnotationComposer,
      $$TouchSamplesTableCreateCompanionBuilder,
      $$TouchSamplesTableUpdateCompanionBuilder,
      (TouchSampleRow, $$TouchSamplesTableReferences),
      TouchSampleRow,
      PrefetchHooks Function({bool actionId})
    >;

class $HandsDatabaseManager {
  final _$HandsDatabase _db;
  $HandsDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ExerciseRunsTableTableManager get exerciseRuns =>
      $$ExerciseRunsTableTableManager(_db, _db.exerciseRuns);
  $$TrialsTableTableManager get trials =>
      $$TrialsTableTableManager(_db, _db.trials);
  $$PausesTableTableManager get pauses =>
      $$PausesTableTableManager(_db, _db.pauses);
  $$ActionsTableTableManager get actions =>
      $$ActionsTableTableManager(_db, _db.actions);
  $$TouchSamplesTableTableManager get touchSamples =>
      $$TouchSamplesTableTableManager(_db, _db.touchSamples);
}
