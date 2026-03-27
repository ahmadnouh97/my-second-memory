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
