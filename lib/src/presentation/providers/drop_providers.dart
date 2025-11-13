// trong file drop_providers.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:quicksender/src/domain/services/local_drop_service.dart';
import 'package:quicksender/src/presentation/providers/network_providers.dart';

final localDropServiceProvider = ChangeNotifierProvider<LocalDropService>((ref) {
  final networkService = ref.watch(networkDiscoveryServiceProvider);
  return LocalDropService(networkService);
});