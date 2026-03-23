// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
  id: json['id'] as String,
  url: json['url'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String?,
  contentType: $enumDecode(_$ContentTypeEnumMap, json['content_type']),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  thumbnailUrl: json['thumbnail_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'summary': instance.summary,
      'content_type': _$ContentTypeEnumMap[instance.contentType]!,
      'tags': instance.tags,
      'thumbnail_url': instance.thumbnailUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ContentTypeEnumMap = {
  ContentType.youtube: 'youtube',
  ContentType.instagram: 'instagram',
  ContentType.article: 'article',
  ContentType.link: 'link',
};

_$PaginatedResponseImpl _$$PaginatedResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PaginatedResponseImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => Item.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$$PaginatedResponseImplToJson(
  _$PaginatedResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
};

_$ExtractPreviewImpl _$$ExtractPreviewImplFromJson(Map<String, dynamic> json) =>
    _$ExtractPreviewImpl(
      url: json['url'] as String,
      contentType: $enumDecode(_$ContentTypeEnumMap, json['content_type']),
      title: json['title'] as String,
      summary: json['summary'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      thumbnailUrl: json['thumbnail_url'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$$ExtractPreviewImplToJson(
  _$ExtractPreviewImpl instance,
) => <String, dynamic>{
  'url': instance.url,
  'content_type': _$ContentTypeEnumMap[instance.contentType]!,
  'title': instance.title,
  'summary': instance.summary,
  'tags': instance.tags,
  'thumbnail_url': instance.thumbnailUrl,
  'content': instance.content,
};
