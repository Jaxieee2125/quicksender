// trong file: lib/src/core/utils/dialogs.dart
import 'package:flutter/material.dart';

// Đảm bảo hàm của bạn trông giống hệt như thế này
void showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}