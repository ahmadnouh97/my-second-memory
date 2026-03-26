import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class TagCount with _$TagCount {
  const factory TagCount({
    required String tag,
    required int count,
  }) = _TagCount;

  factory TagCount.fromJson(Map<String, dynamic> json) =>
      _$TagCountFromJson(json);
}

@freezed
class MergeGroup with _$MergeGroup {
  const factory MergeGroup({
    required String canonical,
    required List<String> merged,
    @JsonKey(name: 'items_affected') required int itemsAffected,
  }) = _MergeGroup;

  factory MergeGroup.fromJson(Map<String, dynamic> json) =>
      _$MergeGroupFromJson(json);
}

@freezed
class ConsolidateResponse with _$ConsolidateResponse {
  const factory ConsolidateResponse({
    required List<MergeGroup> groups,
    @JsonKey(name: 'total_tags_before') required int totalTagsBefore,
    @JsonKey(name: 'total_tags_after') required int totalTagsAfter,
  }) = _ConsolidateResponse;

  factory ConsolidateResponse.fromJson(Map<String, dynamic> json) =>
      _$ConsolidateResponseFromJson(json);
}
