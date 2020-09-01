// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rss_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RssEntity _$RssEntityFromJson(Map<String, dynamic> json) {
  return RssEntity(
    json['id'] as int,
    json['title'] as String,
    json['url'] as String,
    json['type'] as String,
  );
}

Map<String, dynamic> _$RssEntityToJson(RssEntity instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'type': instance.type,
    };
