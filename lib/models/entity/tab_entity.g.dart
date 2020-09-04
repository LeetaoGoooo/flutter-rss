// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabEntity _$TabEntityFromJson(Map<String, dynamic> json) {
  return TabEntity(
    (json['rss'] as List)
        ?.map((e) =>
            e == null ? null : RssEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['feeds'] as List)
        ?.map((e) =>
            e == null ? null : FeedsEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TabEntityToJson(TabEntity instance) => <String, dynamic>{
      'rss': instance.rss,
      'feeds': instance.feeds,
    };
