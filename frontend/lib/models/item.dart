import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

enum ContentType {
  @JsonValue('youtube') youtube,
  @JsonValue('instagram') instagram,
  @JsonValue('linkedin') linkedin,
  @JsonValue('github') github,
  @JsonValue('facebook') facebook,
  @JsonValue('tiktok') tiktok,
  @JsonValue('reddit') reddit,
  @JsonValue('other') other,
}

@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String url,
    required String title,
    String? summary,
    @JsonKey(name: 'content_type', unknownEnumValue: ContentType.other) required ContentType contentType,
    @Default([]) List<String> tags,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

@freezed
class PaginatedResponse with _$PaginatedResponse {
  const factory PaginatedResponse({
    required List<Item> items,
    required int total,
    required int page,
    required int limit,
  }) = _PaginatedResponse;

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedResponseFromJson(json);
}

class ImportResult {
  const ImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
  });

  final int imported;
  final int skipped;
  final List<String> errors;

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(
        imported: json['imported'] as int,
        skipped: json['skipped'] as int,
        errors: (json['errors'] as List<dynamic>).cast<String>(),
      );
}

@freezed
class ExtractPreview with _$ExtractPreview {
  const factory ExtractPreview({
    required String url,
    @JsonKey(name: 'content_type', unknownEnumValue: ContentType.other) required ContentType contentType,
    required String title,
    String? summary,
    @Default([]) List<String> tags,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    String? content,
  }) = _ExtractPreview;

  factory ExtractPreview.fromJson(Map<String, dynamic> json) =>
      _$ExtractPreviewFromJson(json);
}
