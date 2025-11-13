// trong file: lib/src/presentation/providers/repository_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/domain/repositories/settings_repository.dart';
import 'package:quicksender/src/presentation/providers/database_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});