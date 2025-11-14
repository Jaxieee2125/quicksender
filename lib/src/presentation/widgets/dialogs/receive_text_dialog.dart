// lib/src/presentation/widgets/dialogs/receive_text_dialog.dart
import 'package:flutter/material.dart';
import 'package:quicksender/src/data/models/device.dart';

class ReceiveTextDialog extends StatelessWidget {
  final Device sender;
  final String message;
  final VoidCallback onCopy;
  final VoidCallback onClose;

  const ReceiveTextDialog({
    super.key,
    required this.sender,
    required this.message,
    required this.onCopy,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.devices, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              sender.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'đã gửi cho bạn một tin nhắn:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: SingleChildScrollView(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onCopy,
              child: const Text('Sao chép'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              label: const Text('Đóng'),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}