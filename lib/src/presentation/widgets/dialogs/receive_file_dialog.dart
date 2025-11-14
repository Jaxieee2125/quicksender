// lib/src/presentation/widgets/dialogs/receive_file_dialog.dart
import 'package:flutter/material.dart';
import 'package:quicksender/src/data/models/device.dart';

class ReceiveFileDialog extends StatelessWidget {
  final Device sender;
  final int fileCount;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  const ReceiveFileDialog({
    super.key,
    required this.sender,
    required this.fileCount,
    required this.onDecline,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Nền trong suốt để thấy barrierColor
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(Icons.devices, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              sender.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'muốn gửi cho bạn $fileCount file',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(Icons.close),
                  label: const Text('Từ chối'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 24),
                FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check),
                  label: const Text('Chấp nhận'),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}