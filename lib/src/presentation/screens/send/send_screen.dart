// trong file: lib/src/presentation/screens/send/send_screen.dart
// Cần cho Platform
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:quicksender/src/data/models/device.dart';
import 'package:quicksender/src/presentation/providers/network_providers.dart';
import 'package:quicksender/src/presentation/providers/transfer_providers.dart';
import 'package:quicksender/src/presentation/widgets/empty_state_widget.dart';
import 'package:quicksender/src/core/utils/formatters.dart'; // Dùng hàm formatBytes

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  // === STATE CỦA MÀN HÌNH ===
  
  /// Danh sách các file người dùng đã chọn để gửi.
  final List<PlatformFile> _selectedFiles = [];

  String? _selectedText; 
  
  /// Set chứa ID của các thiết bị người dùng đã chọn để gửi đến.
  /// Dùng Set để tránh trùng lặp và truy xuất nhanh.
  final Set<String> _selectedDeviceIds = {};

  // === CÁC HÀM XỬ LÝ ===
  
  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }
  
  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  void _sendRequest() {

    final bool hasSomethingToSend = _selectedFiles.isNotEmpty || (_selectedText != null && _selectedText!.isNotEmpty);

    if (!hasSomethingToSend || _selectedDeviceIds.isEmpty) {
    // SỬA LẠI CÂU THÔNG BÁO CHO CHÍNH XÁC HƠN
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng chọn ít nhất một file/text và một thiết bị nhận.')),
    );
    return;
  }

    final transferService = ref.read(fileTransferServiceProvider);
  //final chatService = ref.read(chatServiceProvider); // Giả sử bạn có ChatService
  final allDevices = ref.read(onlineDevicesProvider).value ?? [];
  final networkService = ref.read(networkDiscoveryServiceProvider);

  final deviceIdsToSend = List<String>.from(_selectedDeviceIds);
  final filesToSend = List<PlatformFile>.from(_selectedFiles);
  final textToSend = _selectedText; // String là kiểu immutable, không cần sao chép

  for (final deviceId in deviceIdsToSend) {
    final targetDevice = allDevices.firstWhere((d) => d.id == deviceId);
    
    // Gửi file nếu có
    if (_selectedFiles.isNotEmpty) {
      transferService.requestToSendFiles(targetDevice, filesToSend);
    }
    
    // Gửi text nếu có
     if (_selectedText != null && _selectedText!.isNotEmpty) {
      networkService.sendTextMessage(targetDevice, textToSend!);
    }
  }
    // Reset lại state sau khi gửi
    setState(() {
      _selectedFiles.clear();
       _selectedText = null;
      _selectedDeviceIds.clear();
    });
  }

  // === HÀM BUILD WIDGET ===
  @override
Widget build(BuildContext context) {
  final onlineDevicesAsync = ref.watch(onlineDevicesProvider);
  // Biến kiểm tra xem có gì để gửi không
  final bool hasSomethingToSend = _selectedFiles.isNotEmpty || (_selectedText != null && _selectedText!.isNotEmpty);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Gửi'),
      actions: [
        // Nút xóa tất cả lựa chọn
        if (hasSomethingToSend)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Xóa tất cả lựa chọn',
            onPressed: () {
              setState(() {
                _selectedFiles.clear();
                _selectedText = null;
              });
            },
          ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =======================================================
          // === PHẦN 1: CÁC NÚT HÀNH ĐỘNG (SELECTION) ===
          // =======================================================
          Text('Lựa chọn', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(context, icon: Icons.description, label: 'File', onTap: _pickFiles),
              _buildActionButton(context, icon: Icons.folder_open, label: 'Thư mục', onTap: _pickFolder),
              _buildActionButton(context, icon: Icons.notes, label: 'Text', onTap: _enterText),
              _buildActionButton(context, icon: Icons.paste, label: 'Paste', onTap: _pasteFromClipboard),
            ],
          ),

          // Hiển thị "khay chờ gửi" nếu có
          if (hasSomethingToSend)
            _buildSelectionPreview(),

          const SizedBox(height: 24),

          // =======================================================
          // === PHẦN 2: CHỌN NGƯỜI NHẬN (NEARBY DEVICES) ===
          // =======================================================
          Row(
            children: [
              Expanded(child: Text('Thiết bị trong mạng', style: Theme.of(context).textTheme.titleMedium)),
              IconButton(onPressed: (){}, icon: const Icon(Icons.refresh), tooltip: 'Làm mới'),
            ],
          ),
          const Divider(),
          Expanded(
            child: onlineDevicesAsync.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.wifi_off_rounded,
                    message: 'Không tìm thấy thiết bị nào.',
                  );
                }
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isSelected = _selectedDeviceIds.contains(device.id);
                    
                    return CheckboxListTile(
                      secondary: Icon(_getIconForOS(device.os)),
                      title: Text(device.name),
                      subtitle: Text(device.ipAddress),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedDeviceIds.add(device.id);
                          } else {
                            _selectedDeviceIds.remove(device.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: hasSomethingToSend && _selectedDeviceIds.isNotEmpty
      ? FloatingActionButton.extended(
          onPressed: _sendRequest,
          label: const Text('Gửi'),
          icon: const Icon(Icons.send),
        )
      : null, // Ẩn nút nếu chưa chọn gì
  );
}

Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

void _pickFolder() async {
  // 1. Yêu cầu người dùng chọn một đường dẫn thư mục
  final String? directoryPath = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Chọn thư mục để gửi',
  );

  if (directoryPath == null) {
    // Người dùng đã hủy
    return;
  }

  // 2. Duyệt qua thư mục để tìm tất cả các file
  final dir = Directory(directoryPath);
  // `listSync` với `recursive: true` sẽ đi vào tất cả các thư mục con
  final List<FileSystemEntity> entities = dir.listSync(recursive: true);
  final List<PlatformFile> filesInDir = [];

  for (final entity in entities) {
    // Chỉ lấy các file, bỏ qua các thư mục con
    if (entity is File) {
      filesInDir.add(
        PlatformFile(
          name: entity.path.split(Platform.pathSeparator).last, // Lấy tên file
          path: entity.path,
          size: entity.lengthSync(),
        ),
      );
    }
  }

  if (filesInDir.isNotEmpty) {
    // 3. Thêm các file tìm được vào danh sách và cập nhật UI
    setState(() {
      _selectedFiles.addAll(filesInDir);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${filesInDir.length} file từ thư mục.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thư mục đã chọn không có file nào.')),
    );
  }
}

void _enterText() async {
  // Mở một dialog để người dùng nhập text
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController(text: _selectedText);
      return AlertDialog(
        title: const Text('Nhập Text để gửi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Xong'),
          ),
        ],
      );
    },
  );

  if (result != null) {
    setState(() {
      _selectedText = result.trim();
    });
  }
}

void _pasteFromClipboard() async {
  final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  if (clipboardData != null && clipboardData.text != null) {
    setState(() {
      _selectedText = clipboardData.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã dán từ clipboard.')),
    );
  }
}

// HÀM HELPER ĐỂ HIỂN THỊ "KHAY CHỜ GỬI"
Widget _buildSelectionPreview() {
  return Card(
    margin: const EdgeInsets.only(top: 16),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị text đã chọn
          if (_selectedText != null && _selectedText!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text(
                _selectedText!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _selectedText = null),
              ),
            ),
          // Hiển thị danh sách file đã chọn
          if (_selectedFiles.isNotEmpty)
            ..._selectedFiles.map((file) => ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(file.name, overflow: TextOverflow.ellipsis),
                  subtitle: Text(formatBytes(file.size, 1)), // Dùng hàm formatBytes đã có
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _removeFile(file),
                  ),
                )),
        ],
      ),
    ),
  );
}

  // Hàm helper để lấy icon (bạn có thể copy từ HomeScreen cũ)
  IconData _getIconForOS(DeviceOS os) {
    switch (os) {
      case DeviceOS.windows:
        return Icons.desktop_windows;
      case DeviceOS.android:
        return Icons.phone_android;
      case DeviceOS.ios:
        return Icons.phone_iphone;
      case DeviceOS.linux:
        return Icons.laptop;
      case DeviceOS.macos:
        return Icons.laptop_mac;
      default:
        return Icons.devices;
    }
  }
}