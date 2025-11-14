import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/presentation/providers/theme_provider.dart';
import 'package:quicksender/src/presentation/screens/main_screen_shell.dart';

void main() {
  runApp(
    // Bọc toàn bộ ứng dụng trong ProviderScope để các provider hoạt động
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
    Widget build(BuildContext context, WidgetRef ref) {
      final themeNotifier = ref.watch(themeProvider);
      return MaterialApp(
      title: 'QuickSender',
      debugShowCheckedModeBanner: false, // Tắt banner "DEBUG"

      // === GIAO DIỆN SÁNG (LIGHT THEME) ===
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          // THAY ĐỔI TỪ `Colors.deepPurple` THÀNH `Colors.cyan`
          seedColor: Colors.lightBlue, 
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // === GIAO DIỆN TỐI (DARK THEME) ===
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          // THAY ĐỔI TỪ `Colors.deepPurple` THÀNH `Colors.cyan`
          seedColor: Colors.lightBlue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Lắng nghe provider để tự động đổi theme
      themeMode: themeNotifier.themeMode,

      home: const MainScreenShell(),
    );
    }
}