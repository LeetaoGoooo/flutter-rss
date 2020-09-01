// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogEntity _$CatalogEntityFromJson(Map<String, dynamic> json) {
  return CatalogEntity(
    json['id'] as int,
    json['catalog'] as String,
  );
}

Map<String, dynamic> _$CatalogEntityToJson(CatalogEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'catalog': instance.catalog,
    };
