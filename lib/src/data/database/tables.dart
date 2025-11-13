// lib/src/data/database/tables.dart
import 'package:drift/drift.dart';

class TransferHistory extends Table {
  TextColumn get sessionId => text()();
  TextColumn get type => text()(); // 'send' or 'receive'
  TextColumn get targetDeviceName => text()();
  TextColumn get targetDeviceIp => text()();
  TextColumn get fileNames => text()(); // Sẽ lưu dưới dạng JSON string
  IntColumn get totalSize => integer()();
  TextColumn get status => text()(); // 'completed' or 'failed'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  

  @override
  Set<Column> get primaryKey => {sessionId};
}

class AppSettings extends Table {
  TextColumn get settingKey => text()(); // Ví dụ: 'deviceName', 'downloadPath'
  TextColumn get settingValue => text()();

  @override
  Set<Column> get primaryKey => {settingKey};
}