// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_drop_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalDropItem _$LocalDropItemFromJson(Map<String, dynamic> json) =>
    LocalDropItem(
      itemId: json['itemId'] as String,
      sourceDevice: Device.fromJson(
        json['sourceDevice'] as Map<String, dynamic>,
      ),
      itemType: $enumDecode(_$ItemTypeEnumMap, json['itemType']),
      content: json['content'] as String,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      port: (json['port'] as num).toInt(),
    );

Map<String, dynamic> _$LocalDropItemToJson(LocalDropItem instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'sourceDevice': instance.sourceDevice,
      'itemType': _$ItemTypeEnumMap[instance.itemType]!,
      'content': instance.content,
      'fileSize': instance.fileSize,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'port': instance.port,
    };

const _$ItemTypeEnumMap = {ItemType.text: 'text', ItemType.file: 'file'};
