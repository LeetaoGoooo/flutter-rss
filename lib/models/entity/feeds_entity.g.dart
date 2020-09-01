// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeds_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedsEntity _$FeedsEntityFromJson(Map<String, dynamic> json) {
  return FeedsEntity(
    json['id'] as int,
    json['title'] as String,
    json['url'] as String,
    json['author'] as String,
    json['published'] as String,
    json['content'] as String,
    json['catalogId'] as int,
    json['rssId'] as int,
    json['status'] as int,
  );
}

Map<String, dynamic> _$FeedsEntityToJson(FeedsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'author': instance.author,
      'published': instance.published,
      'content': instance.content,
      'catalogId': instance.catalogId,
      'rssId': instance.rssId,
      'status': instance.status,
    };
