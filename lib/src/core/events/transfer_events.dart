// lib/src/core/events/transfer_events.dart

/// Lớp cha cho tất cả các sự kiện liên quan đến truyền file.
abstract class TransferEvent {}

/// Sự kiện được phát ra khi checksum không khớp.
class ChecksumMismatchEvent extends TransferEvent {
  final String fileName;
  ChecksumMismatchEvent(this.fileName);
}

/// Sự kiện được phát ra khi không đủ dung lượng lưu trữ.
class NotEnoughSpaceEvent extends TransferEvent {
  final double requiredSpaceMB;
  final double freeSpaceMB;
  NotEnoughSpaceEvent(this.requiredSpaceMB, this.freeSpaceMB);
}

/// Sự kiện được phát ra khi kết nối để resume bị thất bại (timeout).
class ResumeFailedEvent extends TransferEvent {}

/// Một sự kiện chung cho các lỗi không xác định.
class GenericErrorEvent extends TransferEvent {
  final String message;
  GenericErrorEvent(this.message);
}