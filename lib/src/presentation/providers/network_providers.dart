
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quicksender/src/data/models/device.dart';
import 'package:quicksender/src/domain/services/network_discovery_service.dart';
import 'package:quicksender/src/presentation/providers/repository_providers.dart';
import 'package:quicksender/src/presentation/providers/drop_providers.dart';

// 1. Cung cấp một instance duy nhất của service
final networkDiscoveryServiceProvider = ChangeNotifierProvider<NetworkDiscoveryService>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  
  final service = NetworkDiscoveryService(settingsRepo);
  service.start();

  // Tự động hủy service khi không còn được sử dụng
  // ref.onDispose(() => service.dispose());

  return service;
});

// 2. Cung cấp stream các thiết bị đang online
final onlineDevicesProvider = StreamProvider<List<Device>>((ref) {
  // Watch ChangeNotifierProvider để lấy instance của service
  final service = ref.watch(networkDiscoveryServiceProvider);
  // Trả về stream của service đó
  return service.onlineDevicesStream;
});

// 3. Cung cấp stream các yêu cầu truyền file đến
final incomingTransferRequestsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(networkDiscoveryServiceProvider);
  return service.incomingTransferRequestsStream;
});

final currentDeviceProvider = Provider<Device?>((ref) {
  // Bây giờ, `watch` sẽ lắng nghe các thay đổi từ `ChangeNotifier`
  final service = ref.watch(networkDiscoveryServiceProvider);
  return service.thisDevice;
});

final incomingTextMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  // Watch provider chính để lấy instance của service
  final networkService = ref.watch(networkDiscoveryServiceProvider);
  // Trả về stream tin nhắn text của service đó
  return networkService.incomingTextMessagesStream;
});
