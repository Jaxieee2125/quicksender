// trong file: lib/src/presentation/providers/settings_providers.dart
import 'package:flutter_riverpod/legacy.dart';

/// Quản lý trạng thái của cài đặt "Quick Save" (Tự động chấp nhận file).
/// `false` = luôn hỏi, `true` = tự động chấp nhận.
final quickSaveProvider = StateProvider<bool>((ref) => false);