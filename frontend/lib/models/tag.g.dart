// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagCountImpl _$$TagCountImplFromJson(Map<String, dynamic> json) =>
    _$TagCountImpl(
      tag: json['tag'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$TagCountImplToJson(_$TagCountImpl instance) =>
    <String, dynamic>{'tag': instance.tag, 'count': instance.count};

_$MergeGroupImpl _$$MergeGroupImplFromJson(Map<String, dynamic> json) =>
    _$MergeGroupImpl(
      canonical: json['canonical'] as String,
      merged: (json['merged'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      itemsAffected: (json['items_affected'] as num).toInt(),
    );

Map<String, dynamic> _$$MergeGroupImplToJson(_$MergeGroupImpl instance) =>
    <String, dynamic>{
      'canonical': instance.canonical,
      'merged': instance.merged,
      'items_affected': instance.itemsAffected,
    };

_$ConsolidateResponseImpl _$$ConsolidateResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConsolidateResponseImpl(
  groups: (json['groups'] as List<dynamic>)
      .map((e) => MergeGroup.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalTagsBefore: (json['total_tags_before'] as num).toInt(),
  totalTagsAfter: (json['total_tags_after'] as num).toInt(),
);

Map<String, dynamic> _$$ConsolidateResponseImplToJson(
  _$ConsolidateResponseImpl instance,
) => <String, dynamic>{
  'groups': instance.groups,
  'total_tags_before': instance.totalTagsBefore,
  'total_tags_after': instance.totalTagsAfter,
};
