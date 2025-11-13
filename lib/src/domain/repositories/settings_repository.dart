// trong file: lib/src/domain/repositories/settings_repository.dart
import 'package:drift/drift.dart';
import 'package:quicksender/src/data/database/app_database.dart';

class SettingsRepository {
  final AppDatabase _db;
  SettingsRepository(this._db);

  Future<String?> getSetting(String key) async {
    final setting = await (_db.select(_db.appSettings)
          ..where((tbl) => tbl.settingKey.equals(key)))
        .getSingleOrNull();
    return setting?.settingValue;
  }

  Future<void> saveSetting(String key, String value) {
    final setting = AppSettingsCompanion.insert(
      settingKey: key,
      settingValue: value,
    );
    // Dùng `InsertMode.replace` để nếu key đã tồn tại thì cập nhật, nếu chưa thì tạo mới.
    return _db.into(_db.appSettings).insert(setting, mode: InsertMode.replace);
  }
}