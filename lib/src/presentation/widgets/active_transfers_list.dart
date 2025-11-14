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
              
              return ListTile(
                leading: Icon(session.type == TransferType.send ? Icons.upload : Icons.download, size: 24),
                title: Text(
                  session.files.length > 1 
                      ? '${session.files.length} files' 
                      : session.files.first.fileName,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                // =========================================================
                // === ĐÂY LÀ VỊ TRÍ ĐỂ GỌI HÀM HELPER CỦA BẠN ===
                // `trailing` là widget hiển thị ở cuối cùng bên phải của ListTile
                // =========================================================
                trailing: _buildTrailingWidget(ref, session),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingWidget(WidgetRef ref, TransferSession session) {
    // TÍNH TOÁN TIẾN TRÌNH
    final progress = session.totalSize > 0
        ? session.transferredSize / session.totalSize
        : 0.0;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    // Xử lý các trạng thái khác nhau của session
    switch (session.status) {
      
      // TRƯỜNG HỢP 1: ĐANG KẾT NỐI
      case TransferStatus.connecting:
      case TransferStatus.accepted:
        return const SizedBox(
          width: 48, // Giữ cho layout ổn định
          height: 24,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        );

      // TRƯỜNG HỢP 2: ĐANG TRUYỀN FILE
      case TransferStatus.transferring:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$progressPercent%'),
            _buildPauseResumeButton(ref, session), // Nút Pause
            _buildCancelButton(ref, session),      // Nút Cancel
          ],
        );

      // TRƯỜNG HỢP 3: ĐÃ TẠM DỪNG
      case TransferStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$progressPercent%'),
            _buildPauseResumeButton(ref, session), // Nút Play
            _buildCancelButton(ref, session),      // Nút Cancel
          ],
        );

      // CÁC TRƯỜNG HỢP KHÁC (pending, completed, failed...)
      default:
        // Không hiển thị gì hoặc một icon chờ
        return const SizedBox(
          width: 48,
          height: 24,
          child: Center(child: Icon(Icons.hourglass_empty, size: 20)),
        );
    }
  }

  Widget _buildCancelButton(WidgetRef ref, TransferSession session) {
    final transferService = ref.read(fileTransferServiceProvider);
    return IconButton(
      icon: const Icon(Icons.close),
      tooltip: 'Hủy',
      onPressed: () => transferService.cancelTransfer(session.sessionId),
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