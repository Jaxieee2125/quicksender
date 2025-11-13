import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/presentation/providers/theme_provider.dart';
import 'package:quicksender/src/presentation/screens/home_screen.dart';

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
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: themeNotifier.themeMode, // Lắng nghe sự thay đổi
        home: const HomeScreen(),
      );
    }
}