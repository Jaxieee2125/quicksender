// lib/src/presentation/providers/database_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/data/database/app_database.dart';

// Cung cấp một instance duy nhất của AppDatabase
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});