// lib/src/presentation/providers/transfer_providers.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:quicksender/src/domain/services/file_transfer_service.dart';
import 'package:quicksender/src/domain/services/sound_service.dart';
import 'package:quicksender/src/presentation/providers/database_providers.dart';
import 'package:quicksender/src/presentation/providers/network_providers.dart';

// Cung cấp một instance duy nhất của FileTransferService
final fileTransferServiceProvider = ChangeNotifierProvider<FileTransferService>((ref) {
  final networkService = ref.watch(networkDiscoveryServiceProvider);
  final db = ref.watch(databaseProvider); // Thêm dòng này
  final soundService = SoundService();
  return FileTransferService(networkService, db, soundService); // Truyền db vào
});