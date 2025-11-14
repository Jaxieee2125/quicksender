import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'device.g.dart'; // File này sẽ được tạo tự động

enum DeviceStatus { online, offline }
enum DeviceOS { windows, macos, linux, android, ios, web, unknown }

@JsonSerializable()
class Device extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final DeviceOS os;
  final DeviceStatus status;
  final List<String> hostedItems; // Danh sách ID các item đang được host bởi thiết bị này

  const Device({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.os,
    this.status = DeviceStatus.online,
    this.hostedItems = const [],
  });

  // Chuyển đổi từ JSON
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  @override
  List<Object?> get props => [id, name, ipAddress, port, os, status];
}