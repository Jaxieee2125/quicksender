// trong file: lib/src/core/utils/formatters.dart
import 'dart:math';

/// Chuyển đổi số byte thành một chuỗi dễ đọc (B, KB, MB, GB, TB).
///
/// [bytes]: Số byte cần format.
/// [decimals]: Số chữ số thập phân mong muốn. Mặc định là 1.
String formatBytes(int bytes, [int decimals = 1]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}