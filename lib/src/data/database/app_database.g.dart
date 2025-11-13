// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransferHistoryTable extends TransferHistory
    with TableInfo<$TransferHistoryTable, TransferHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferHistoryTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDeviceNameMeta = const VerificationMeta(
    'targetDeviceName',
  );
  @override
  late final GeneratedColumn<String> targetDeviceName = GeneratedColumn<String>(
    'target_device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDeviceIpMeta = const VerificationMeta(
    'targetDeviceIp',
  );
  @override
  late final GeneratedColumn<String> targetDeviceIp = GeneratedColumn<String>(
    'target_device_ip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNamesMeta = const VerificationMeta(
    'fileNames',
  );
  @override
  late final GeneratedColumn<String> fileNames = GeneratedColumn<String>(
    'file_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSizeMeta = const VerificationMeta(
    'totalSize',
  );
  @override
  late final GeneratedColumn<int> totalSize = GeneratedColumn<int>(
    'total_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
  List<GeneratedColumn> get $columns => [
    sessionId,
    type,
    targetDeviceName,
    targetDeviceIp,
    fileNames,
    totalSize,
    status,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfer_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransferHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_device_name')) {
      context.handle(
        _targetDeviceNameMeta,
        targetDeviceName.isAcceptableOrUnknown(
          data['target_device_name']!,
          _targetDeviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDeviceNameMeta);
    }
    if (data.containsKey('target_device_ip')) {
      context.handle(
        _targetDeviceIpMeta,
        targetDeviceIp.isAcceptableOrUnknown(
          data['target_device_ip']!,
          _targetDeviceIpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDeviceIpMeta);
    }
    if (data.containsKey('file_names')) {
      context.handle(
        _fileNamesMeta,
        fileNames.isAcceptableOrUnknown(data['file_names']!, _fileNamesMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNamesMeta);
    }
    if (data.containsKey('total_size')) {
      context.handle(
        _totalSizeMeta,
        totalSize.isAcceptableOrUnknown(data['total_size']!, _totalSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_totalSizeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  TransferHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransferHistoryData(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      targetDeviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_device_name'],
      )!,
      targetDeviceIp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_device_ip'],
      )!,
      fileNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_names'],
      )!,
      totalSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_size'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $TransferHistoryTable createAlias(String alias) {
    return $TransferHistoryTable(attachedDatabase, alias);
  }
}

class TransferHistoryData extends DataClass
    implements Insertable<TransferHistoryData> {
  final String sessionId;
  final String type;
  final String targetDeviceName;
  final String targetDeviceIp;
  final String fileNames;
  final int totalSize;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  const TransferHistoryData({
    required this.sessionId,
    required this.type,
    required this.targetDeviceName,
    required this.targetDeviceIp,
    required this.fileNames,
    required this.totalSize,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['type'] = Variable<String>(type);
    map['target_device_name'] = Variable<String>(targetDeviceName);
    map['target_device_ip'] = Variable<String>(targetDeviceIp);
    map['file_names'] = Variable<String>(fileNames);
    map['total_size'] = Variable<int>(totalSize);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  TransferHistoryCompanion toCompanion(bool nullToAbsent) {
    return TransferHistoryCompanion(
      sessionId: Value(sessionId),
      type: Value(type),
      targetDeviceName: Value(targetDeviceName),
      targetDeviceIp: Value(targetDeviceIp),
      fileNames: Value(fileNames),
      totalSize: Value(totalSize),
      status: Value(status),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory TransferHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransferHistoryData(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      targetDeviceName: serializer.fromJson<String>(json['targetDeviceName']),
      targetDeviceIp: serializer.fromJson<String>(json['targetDeviceIp']),
      fileNames: serializer.fromJson<String>(json['fileNames']),
      totalSize: serializer.fromJson<int>(json['totalSize']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'type': serializer.toJson<String>(type),
      'targetDeviceName': serializer.toJson<String>(targetDeviceName),
      'targetDeviceIp': serializer.toJson<String>(targetDeviceIp),
      'fileNames': serializer.toJson<String>(fileNames),
      'totalSize': serializer.toJson<int>(totalSize),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  TransferHistoryData copyWith({
    String? sessionId,
    String? type,
    String? targetDeviceName,
    String? targetDeviceIp,
    String? fileNames,
    int? totalSize,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => TransferHistoryData(
    sessionId: sessionId ?? this.sessionId,
    type: type ?? this.type,
    targetDeviceName: targetDeviceName ?? this.targetDeviceName,
    targetDeviceIp: targetDeviceIp ?? this.targetDeviceIp,
    fileNames: fileNames ?? this.fileNames,
    totalSize: totalSize ?? this.totalSize,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  TransferHistoryData copyWithCompanion(TransferHistoryCompanion data) {
    return TransferHistoryData(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      targetDeviceName: data.targetDeviceName.present
          ? data.targetDeviceName.value
          : this.targetDeviceName,
      targetDeviceIp: data.targetDeviceIp.present
          ? data.targetDeviceIp.value
          : this.targetDeviceIp,
      fileNames: data.fileNames.present ? data.fileNames.value : this.fileNames,
      totalSize: data.totalSize.present ? data.totalSize.value : this.totalSize,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransferHistoryData(')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('targetDeviceName: $targetDeviceName, ')
          ..write('targetDeviceIp: $targetDeviceIp, ')
          ..write('fileNames: $fileNames, ')
          ..write('totalSize: $totalSize, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    type,
    targetDeviceName,
    targetDeviceIp,
    fileNames,
    totalSize,
    status,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransferHistoryData &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.targetDeviceName == this.targetDeviceName &&
          other.targetDeviceIp == this.targetDeviceIp &&
          other.fileNames == this.fileNames &&
          other.totalSize == this.totalSize &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class TransferHistoryCompanion extends UpdateCompanion<TransferHistoryData> {
  final Value<String> sessionId;
  final Value<String> type;
  final Value<String> targetDeviceName;
  final Value<String> targetDeviceIp;
  final Value<String> fileNames;
  final Value<int> totalSize;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const TransferHistoryCompanion({
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.targetDeviceName = const Value.absent(),
    this.targetDeviceIp = const Value.absent(),
    this.fileNames = const Value.absent(),
    this.totalSize = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransferHistoryCompanion.insert({
    required String sessionId,
    required String type,
    required String targetDeviceName,
    required String targetDeviceIp,
    required String fileNames,
    required int totalSize,
    required String status,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       type = Value(type),
       targetDeviceName = Value(targetDeviceName),
       targetDeviceIp = Value(targetDeviceIp),
       fileNames = Value(fileNames),
       totalSize = Value(totalSize),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<TransferHistoryData> custom({
    Expression<String>? sessionId,
    Expression<String>? type,
    Expression<String>? targetDeviceName,
    Expression<String>? targetDeviceIp,
    Expression<String>? fileNames,
    Expression<int>? totalSize,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (targetDeviceName != null) 'target_device_name': targetDeviceName,
      if (targetDeviceIp != null) 'target_device_ip': targetDeviceIp,
      if (fileNames != null) 'file_names': fileNames,
      if (totalSize != null) 'total_size': totalSize,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransferHistoryCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? type,
    Value<String>? targetDeviceName,
    Value<String>? targetDeviceIp,
    Value<String>? fileNames,
    Value<int>? totalSize,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return TransferHistoryCompanion(
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      targetDeviceName: targetDeviceName ?? this.targetDeviceName,
      targetDeviceIp: targetDeviceIp ?? this.targetDeviceIp,
      fileNames: fileNames ?? this.fileNames,
      totalSize: totalSize ?? this.totalSize,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetDeviceName.present) {
      map['target_device_name'] = Variable<String>(targetDeviceName.value);
    }
    if (targetDeviceIp.present) {
      map['target_device_ip'] = Variable<String>(targetDeviceIp.value);
    }
    if (fileNames.present) {
      map['file_names'] = Variable<String>(fileNames.value);
    }
    if (totalSize.present) {
      map['total_size'] = Variable<int>(totalSize.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferHistoryCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('targetDeviceName: $targetDeviceName, ')
          ..write('targetDeviceIp: $targetDeviceIp, ')
          ..write('fileNames: $fileNames, ')
          ..write('totalSize: $totalSize, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta(
    'settingValue',
  );
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(
          data['setting_value']!,
          _settingValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String settingKey;
  final String settingValue;
  const AppSetting({required this.settingKey, required this.settingValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
    };
  }

  AppSetting copyWith({String? settingKey, String? settingValue}) => AppSetting(
    settingKey: settingKey ?? this.settingKey,
    settingValue: settingValue ?? this.settingValue,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String settingKey,
    required String settingValue,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<AppSetting> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransferHistoryTable transferHistory = $TransferHistoryTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transferHistory,
    appSettings,
  ];
}

typedef $$TransferHistoryTableCreateCompanionBuilder =
    TransferHistoryCompanion Function({
      required String sessionId,
      required String type,
      required String targetDeviceName,
      required String targetDeviceIp,
      required String fileNames,
      required int totalSize,
      required String status,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$TransferHistoryTableUpdateCompanionBuilder =
    TransferHistoryCompanion Function({
      Value<String> sessionId,
      Value<String> type,
      Value<String> targetDeviceName,
      Value<String> targetDeviceIp,
      Value<String> fileNames,
      Value<int> totalSize,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$TransferHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $TransferHistoryTable> {
  $$TransferHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDeviceName => $composableBuilder(
    column: $table.targetDeviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDeviceIp => $composableBuilder(
    column: $table.targetDeviceIp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileNames => $composableBuilder(
    column: $table.fileNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSize => $composableBuilder(
    column: $table.totalSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransferHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $TransferHistoryTable> {
  $$TransferHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDeviceName => $composableBuilder(
    column: $table.targetDeviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDeviceIp => $composableBuilder(
    column: $table.targetDeviceIp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileNames => $composableBuilder(
    column: $table.fileNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSize => $composableBuilder(
    column: $table.totalSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransferHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransferHistoryTable> {
  $$TransferHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get targetDeviceName => $composableBuilder(
    column: $table.targetDeviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetDeviceIp => $composableBuilder(
    column: $table.targetDeviceIp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileNames =>
      $composableBuilder(column: $table.fileNames, builder: (column) => column);

  GeneratedColumn<int> get totalSize =>
      $composableBuilder(column: $table.totalSize, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$TransferHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransferHistoryTable,
          TransferHistoryData,
          $$TransferHistoryTableFilterComposer,
          $$TransferHistoryTableOrderingComposer,
          $$TransferHistoryTableAnnotationComposer,
          $$TransferHistoryTableCreateCompanionBuilder,
          $$TransferHistoryTableUpdateCompanionBuilder,
          (
            TransferHistoryData,
            BaseReferences<
              _$AppDatabase,
              $TransferHistoryTable,
              TransferHistoryData
            >,
          ),
          TransferHistoryData,
          PrefetchHooks Function()
        > {
  $$TransferHistoryTableTableManager(
    _$AppDatabase db,
    $TransferHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransferHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransferHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransferHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> targetDeviceName = const Value.absent(),
                Value<String> targetDeviceIp = const Value.absent(),
                Value<String> fileNames = const Value.absent(),
                Value<int> totalSize = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransferHistoryCompanion(
                sessionId: sessionId,
                type: type,
                targetDeviceName: targetDeviceName,
                targetDeviceIp: targetDeviceIp,
                fileNames: fileNames,
                totalSize: totalSize,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String type,
                required String targetDeviceName,
                required String targetDeviceIp,
                required String fileNames,
                required int totalSize,
                required String status,
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransferHistoryCompanion.insert(
                sessionId: sessionId,
                type: type,
                targetDeviceName: targetDeviceName,
                targetDeviceIp: targetDeviceIp,
                fileNames: fileNames,
                totalSize: totalSize,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransferHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransferHistoryTable,
      TransferHistoryData,
      $$TransferHistoryTableFilterComposer,
      $$TransferHistoryTableOrderingComposer,
      $$TransferHistoryTableAnnotationComposer,
      $$TransferHistoryTableCreateCompanionBuilder,
      $$TransferHistoryTableUpdateCompanionBuilder,
      (
        TransferHistoryData,
        BaseReferences<
          _$AppDatabase,
          $TransferHistoryTable,
          TransferHistoryData
        >,
      ),
      TransferHistoryData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String settingKey,
      required String settingValue,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> settingKey,
      Value<String> settingValue,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransferHistoryTableTableManager get transferHistory =>
      $$TransferHistoryTableTableManager(_db, _db.transferHistory);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
