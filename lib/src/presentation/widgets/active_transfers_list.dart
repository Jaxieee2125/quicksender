import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/core/enums/enums.dart'; // Đảm bảo bạn có file enums
import 'package:quicksender/src/presentation/providers/transfer_providers.dart';
import 'package:quicksender/src/data/models/transfer_session.dart';


class ActiveTransfersList extends ConsumerWidget {
  const ActiveTransfersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferService = ref.watch(fileTransferServiceProvider);
    final sessions = transferService.activeSessions;

    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Đang truyền file",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final progress = session.totalSize > 0
                  ? session.transferredSize / session.totalSize
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(session.type == TransferType.send ? Icons.upload : Icons.download, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            session.files.length > 1 
                                ? '${session.files.length} files' 
                                : session.files.first.fileName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(progress * 100).toStringAsFixed(0)}%'),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Gọi hàm helper để build nút Pause/Resume
                            _buildPauseResumeButton(ref, session),
                            // Nút Cancel
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined),
                              iconSize: 22,
                              tooltip: 'Hủy',
                              onPressed: () {
                                ref.read(fileTransferServiceProvider).cancelTransfer(session.sessionId);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildPauseResumeButton(WidgetRef ref, TransferSession session) {
      final transferService = ref.read(fileTransferServiceProvider);
      debugPrint('Building button for session ${session.sessionId} with status: ${session.status}');

      // KHI ĐANG TRUYỀN -> HIỂN THỊ NÚT PAUSE
      if (session.status == TransferStatus.transferring) {
        return IconButton(
          icon: const Icon(Icons.pause_circle_outline),
          iconSize: 28,
          tooltip: 'Tạm dừng',
          onPressed: () => transferService.pauseTransfer(session.sessionId),
        );
      }
      
      // KHI ĐÃ TẠM DỪNG -> HIỂN THỊ NÚT PLAY
      if (session.status == TransferStatus.paused) {
        return IconButton(
          icon: const Icon(Icons.play_circle_outline),
          iconSize: 28,
          tooltip: 'Tiếp tục',
          onPressed: () {
            // TODO: Gọi hàm resumeTransfer ở bước sau
            transferService.resumeTransfer(session.sessionId);
          },
        );
      }

      // CÁC TRẠNG THÁI KHÁC (pending, completed, failed...) -> KHÔNG HIỂN THỊ GÌ
      return const SizedBox(width: 48); // Dành không gian để layout không bị lệch
    }
  }