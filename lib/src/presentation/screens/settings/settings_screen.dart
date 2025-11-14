import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/presentation/providers/repository_providers.dart';
import 'package:quicksender/src/presentation/providers/theme_provider.dart'; // THÊM IMPORT NÀY

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _deviceNameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentName = await repository.getSetting('deviceName');
    if (mounted && currentName != null) {
      _deviceNameController.text = currentName;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveSetting('deviceName', _deviceNameController.text.trim());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt! Vui lòng khởi động lại ứng dụng để áp dụng tên mới.')),
      );
    }
  }
  
  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // SỬ DỤNG ref.watch Ở ĐÂY ĐỂ UI TỰ ĐỘNG CẬP NHẬT KHI THEME THAY ĐỔI
    // =========================================================================
    final themeNotifier = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // === PHẦN 1: TÊN HIỂN THỊ (CODE CŨ) ===
                Text(
                  'Tên hiển thị',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _deviceNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ví dụ: PC của tôi',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Lưu tên thiết bị'),
                ),

                const Divider(height: 48),

                // =========================================================================
                // === PHẦN 2: GIAO DIỆN (CODE MỚI) ===
                // =========================================================================
                Text(
                  'Giao diện',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                
                // SegmentedButton là một widget hiện đại để chọn một trong nhiều tùy chọn
                SegmentedButton<ThemeMode>(
                  // Các lựa chọn có thể
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Sáng'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Tối'),
                      icon: Icon(Icons.dark_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('Hệ thống'),
                      icon: Icon(Icons.settings_system_daydream),
                    ),
                  ],
                  // Lựa chọn hiện tại, được lấy từ provider
                  selected: {themeNotifier.themeMode},
                  // Cho phép chọn nhiều? Không.
                  multiSelectionEnabled: false,
                  // Không hiển thị icon khi đã chọn để đỡ rối mắt
                  showSelectedIcon: false,
                  // Hàm được gọi khi người dùng chọn một mục mới
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    // ==============================================================
                    // SỬ DỤNG ref.read Ở ĐÂY ĐỂ GỌI HÀM, KHÔNG BUILD LẠI WIDGET
                    // ==============================================================
                    ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
                  },
                )
              ],
            ),
    );
  }
}