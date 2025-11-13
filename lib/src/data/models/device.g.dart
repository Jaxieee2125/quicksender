// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: json['id'] as String,
  name: json['name'] as String,
  ipAddress: json['ipAddress'] as String,
  port: (json['port'] as num).toInt(),
  os: $enumDecode(_$DeviceOSEnumMap, json['os']),
  status:
      $enumDecodeNullable(_$DeviceStatusEnumMap, json['status']) ??
      DeviceStatus.online,
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ipAddress': instance.ipAddress,
  'port': instance.port,
  'os': _$DeviceOSEnumMap[instance.os]!,
  'status': _$DeviceStatusEnumMap[instance.status]!,
};

const _$DeviceOSEnumMap = {
  DeviceOS.windows: 'windows',
  DeviceOS.macos: 'macos',
  DeviceOS.linux: 'linux',
  DeviceOS.android: 'android',
  DeviceOS.ios: 'ios',
  DeviceOS.web: 'web',
  DeviceOS.unknown: 'unknown',
};

const _$DeviceStatusEnumMap = {
  DeviceStatus.online: 'online',
  DeviceStatus.offline: 'offline',
};
