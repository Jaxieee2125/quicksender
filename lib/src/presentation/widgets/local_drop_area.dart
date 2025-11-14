// trong file local_drop_area.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/core/enums/enums.dart';
import 'package:quicksender/src/domain/services/local_drop_service.dart';
import 'package:quicksender/src/presentation/providers/drop_providers.dart';
import 'dart:async'; // Cần cho Timer

class LocalDropArea extends ConsumerStatefulWidget { // Chuyển thành StatefulWidget
  const LocalDropArea({super.key});
  @override
  ConsumerState<LocalDropArea> createState() => _LocalDropAreaState();
}

class _LocalDropAreaState extends ConsumerState<LocalDropArea> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropService = ref.watch(localDropServiceProvider);
    final items = dropService.availableItems;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Dán text hoặc link vào đây...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                tooltip: 'Drop Text',
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    ref.read(localDropServiceProvider).dropText(text);
                    _textController.clear();
                    // Ẩn bàn phím
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.public),
            label: const Text('Drop một file cho mọi người'),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.isNotEmpty) {
                ref.read(localDropServiceProvider).dropFile(result.files.single);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Đang có sẵn trong mạng:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Divider(),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Chưa có item nào được drop.')),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final downloadSession = dropService.activeDownloads.firstWhere(
                    (s) => s.item.itemId == item.itemId,
                    orElse: () => DownloadSession(item), // Trả về một session giả nếu không tìm thấy
                  );
                  final isDownloading = dropService.activeDownloads.any((s) => s.item.itemId == item.itemId);
                  return Card(
                    child: ListTile(
                      leading: Icon(item.itemType == ItemType.file ? Icons.description : Icons.notes),
                      title: Text(item.content, overflow: TextOverflow.ellipsis),
                      subtitle: Text('Từ: ${item.sourceDevice.name}'),
                      // Hiển thị thanh tiến trình hoặc nút download
                      trailing: isDownloading
                          ? _buildProgressIndicator(downloadSession)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ExpirationTimer(expiresAt: item.expiresAt),
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () {
                                    ref.read(localDropServiceProvider).downloadItem(item);
                                  },
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(DownloadSession session) {
  final progress = (session.item.fileSize != null && session.item.fileSize! > 0)
      ? session.bytesReceived / session.item.fileSize!
      : 0.0;
  
  return SizedBox(
    width: 100,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${(progress * 100).toStringAsFixed(0)}%'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
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
        setState(() { _timeLeft = Duration.zero; });
      } else {
        setState(() { _timeLeft = newTimeLeft; });
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
    final seconds = _timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text('$minutes:$seconds');
  }
}