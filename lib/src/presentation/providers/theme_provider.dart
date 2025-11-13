// trong file theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    // TODO: Lưu cài đặt theme vào database để ghi nhớ lựa chọn của người dùng
  }
}

final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});