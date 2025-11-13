// trong file local_drop_item.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:quicksender/src/data/models/device.dart';
import 'package:quicksender/src/core/enums/enums.dart';

part 'local_drop_item.g.dart'; // Chạy build_runner để tạo file này

@JsonSerializable()
class LocalDropItem {
  final String itemId;      // ID duy nhất của item
  final Device sourceDevice;  // Thiết bị đã gửi item
  final ItemType itemType;    // Là text hay file?
  final String content;       // Nội dung text, hoặc tên file
  final int? fileSize;        // Kích thước file (nếu là file)
  final DateTime expiresAt;   // Thời điểm hết hạn
  final int port;             // Port để kết nối và tải item

  LocalDropItem({
    required this.itemId,
    required this.sourceDevice,
    required this.itemType,
    required this.content,
    this.fileSize,
    required this.expiresAt,
    required this.port,
  });

  factory LocalDropItem.fromJson(Map<String, dynamic> json) => _$LocalDropItemFromJson(json);
  Map<String, dynamic> toJson() => _$LocalDropItemToJson(this);
}