// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rss2catalog_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rss2CatalogEntity _$Rss2CatalogEntityFromJson(Map<String, dynamic> json) {
  return Rss2CatalogEntity(
    json['id'] as int,
    json['catalogId'] as int,
    json['rssId'] as int,
  );
}

Map<String, dynamic> _$Rss2CatalogEntityToJson(Rss2CatalogEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'catalogId': instance.catalogId,
      'rssId': instance.rssId,
    };
