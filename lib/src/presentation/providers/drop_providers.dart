// trong file drop_providers.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:quicksender/src/domain/services/local_drop_service.dart';
import 'package:quicksender/src/presentation/providers/network_providers.dart';

final localDropServiceProvider = ChangeNotifierProvider<LocalDropService>((ref) {
  final networkService = ref.watch(networkDiscoveryServiceProvider);
  
  final dropService = LocalDropService(networkService);

  // === ĐÂY LÀ BƯỚC KẾT NỐI ===
  // Đăng ký hàm `getHostedItemIds` của dropService làm callback
  // cho networkService.
  networkService.registerHostedItemsCallback(dropService.getHostedItemIds);
  
  return dropService;
});