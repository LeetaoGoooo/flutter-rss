// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rss_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiRssEntity _$MultiRssEntityFromJson(Map<String, dynamic> json) {
  return MultiRssEntity(
    json['catalogId'] as int,
    json['rssId'] as int,
    json['rssType'] as String,
    json['rssUrl'] as String,
    json['rssTitle'] as String,
  );
}

Map<String, dynamic> _$MultiRssEntityToJson(MultiRssEntity instance) =>
    <String, dynamic>{
      'catalogId': instance.catalogId,
      'rssId': instance.rssId,
      'rssType': instance.rssType,
      'rssUrl': instance.rssUrl,
      'rssTitle': instance.rssTitle,
    };
