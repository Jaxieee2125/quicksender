import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/data/models/device.dart';
import 'package:quicksender/src/domain/services/network_discovery_service.dart';
import 'package:quicksender/src/presentation/providers/repository_providers.dart';

// 1. Cung cấp một instance duy nhất của service
final networkDiscoveryServiceProvider = Provider<NetworkDiscoveryService>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final service = NetworkDiscoveryService(settingsRepo);
  service.start();

  // Tự động hủy service khi không còn được sử dụng
  ref.onDispose(() => service.dispose());

  return service;
});

// 2. Cung cấp stream các thiết bị đang online
final onlineDevicesProvider = StreamProvider<List<Device>>((ref) {
  // Lắng nghe service và trả về stream của nó
  final service = ref.watch(networkDiscoveryServiceProvider);
  return service.onlineDevicesStream;
});

// 3. Cung cấp stream các yêu cầu truyền file đến
final incomingTransferRequestsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(networkDiscoveryServiceProvider);
  return service.incomingTransferRequestsStream;
});