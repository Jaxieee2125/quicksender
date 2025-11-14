// trong file local_drop_area.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/core/enums/enums.dart';
import 'package:quicksender/src/core/utils/formatters.dart';
import 'package:quicksender/src/presentation/providers/drop_providers.dart';
import 'package:quicksender/src/presentation/providers/network_providers.dart';
import 'dart:async';

import 'package:quicksender/src/presentation/widgets/empty_state_widget.dart'; // Cần cho Timer

class DropScreen extends ConsumerStatefulWidget {
  const DropScreen({super.key});
  @override
  ConsumerState<DropScreen> createState() => _DropScreenState();
}

class _DropScreenState extends ConsumerState<DropScreen> {
  final _textController = TextEditingController();
  Duration _selectedLifetime = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi của text field để build lại UI
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _dropText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(localDropServiceProvider).dropText(text, _selectedLifetime);
      _textController.clear();
      FocusScope.of(context).unfocus(); // Ẩn bàn phím
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã drop text vào mạng!')));
    }
  }

  void _dropFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      ref.read(localDropServiceProvider).dropFile(result.files.single, _selectedLifetime);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã drop file vào mạng!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropService = ref.watch(localDropServiceProvider);
    final items = dropService.availableItems;

    final thisDevice = ref.watch(currentDeviceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Local Drop')),
      body: Column(
        // Sử dụng Column thay vì Padding
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =======================================================
          // === PHẦN 2: DANH SÁCH ITEM (ĐƯA LÊN TRÊN) ===
          // =======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Đang có sẵn trong mạng:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          Expanded(
            child: items.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.cloud_off_rounded,
                    message: 'Chưa có item nào được drop.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      // === BƯỚC 2: TÙY CHỈNH ListTile ===
                      final bool isText = item.itemType == ItemType.text;
                      final bool isMyItem = item.sourceDevice.id == thisDevice?.id;
                      final String subtitle = isText
                          ? 'Text • Từ: ${item.sourceDevice.name}'
                          : 'File • Từ: ${item.sourceDevice.name} • ${formatBytes(item.fileSize ?? 0, 1)}';
                      debugPrint('isMyItem: $isMyItem');
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isText ? Icons.notes : Icons.description,
                          ),
                          title: Text(
                            item.content,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          subtitle: Text(subtitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ExpirationTimer(expiresAt: item.expiresAt),
                              if (isMyItem)
                                IconButton(
                                  icon: const Icon(Icons.cancel_outlined),
                                  color: Colors.red.shade400,
                                  tooltip: 'Hủy Drop',
                                  onPressed: () {
                                    ref.read(localDropServiceProvider).cancelDroppedItem(item.itemId);
                                  },
                                )
                              else
                              IconButton(
                                // Icon và tooltip thay đổi theo ngữ cảnh
                                icon: Icon(
                                  isText
                                      ? Icons.copy_all_outlined
                                      : Icons.download_outlined,
                                ),
                                tooltip: isText ? 'Sao chép' : 'Tải về',
                                onPressed: () {
                                  ref
                                      .read(localDropServiceProvider)
                                      .downloadItem(item);

                                  final message = isText
                                      ? 'Đã sao chép vào clipboard!'
                                      : 'Đang bắt đầu tải ${item.content}...';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // =======================================================
          // === PHẦN 1: KHU VỰC NHẬP LIỆU MỚI (ĐẶT Ở DƯỚI CÙNG) ===
          // =======================================================
          Material(
  elevation: 8,
  color: Theme.of(context).colorScheme.surface,
  child: Padding(
    padding: EdgeInsets.only(
      top: 8,
      left: 8,
      right: 8,
      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // === NÚT CHỌN FILE ===
        IconButton(
          icon: const Icon(Icons.attach_file),
          tooltip: 'Drop một file',
          onPressed: _dropFile,
        ),

        // === NÚT CHỌN THỜI GIAN (DÙNG PopupMenuButton) ===
        PopupMenuButton<Duration>(
          icon: const Icon(Icons.timer_outlined),
          tooltip: 'Chọn thời gian tồn tại (${_selectedLifetime.inMinutes} phút)',
          onSelected: (Duration result) {
            setState(() {
              _selectedLifetime = result;
            });
          },
          // Định nghĩa các lựa chọn trong menu
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Duration>>[
            const PopupMenuItem<Duration>(
              value: Duration(minutes: 5),
              child: Text('5 phút'),
            ),
            const PopupMenuItem<Duration>(
              value: Duration(minutes: 30),
              child: Text('30 phút'),
            ),
            const PopupMenuItem<Duration>(
              value: Duration(hours: 1),
              child: Text('1 giờ'),
            ),
            const PopupMenuItem<Duration>(
              value: Duration(days: 1), // Thêm lựa chọn 1 ngày
              child: Text('1 ngày'),
            ),
          ],
        ),

        // === Ô NHẬP TEXT ===
        Expanded(
          child: SizedBox(
          height: 40,
          child: TextField(
            controller: _textController,
            minLines: 1,
            maxLines: 1,
            
            decoration: InputDecoration(
              hintText: 'Nhập nội dung cần drop...',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          ),
        ),
        
        const SizedBox(width: 4),

        // === NÚT GỬI TEXT ===
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: _textController.text.trim().isNotEmpty
              ? FloatingActionButton(
                  key: const ValueKey('send_button'),
                  onPressed: _dropText,
                  mini: true,
                  child: const Icon(Icons.send),
                )
              : const SizedBox(key: ValueKey('empty_space'), width: 0), // Giữ không gian
        ),
      ],
    ),
  ),
),
        ],
      ),
    );
  }
}

// Widget con để hiển thị đồng hồ đếm ngược
class _ExpirationTimer extends StatefulWidget {
  final DateTime expiresAt;
  const _ExpirationTimer({required this.expiresAt});

  @override
  State<_ExpirationTimer> createState() => _ExpirationTimerState();
}

class _ExpirationTimerState extends State<_ExpirationTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;


  @override
  void initState() {
    super.initState();
    _timeLeft = widget.expiresAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newTimeLeft = widget.expiresAt.difference(DateTime.now());
      if (newTimeLeft.isNegative) {
        timer.cancel();
        setState(() {
          _timeLeft = Duration.zero;
        });
      } else {
        setState(() {
          _timeLeft = newTimeLeft;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative || _timeLeft.inSeconds == 0) {
      return const Text('Hết hạn');
    }
    final minutes = _timeLeft.inMinutes.remainder(60).toString();
    final seconds = _timeLeft.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return Text('$minutes:$seconds');
  }
}
