// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TagCount _$TagCountFromJson(Map<String, dynamic> json) {
  return _TagCount.fromJson(json);
}

/// @nodoc
mixin _$TagCount {
  String get tag => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this TagCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TagCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagCountCopyWith<TagCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCountCopyWith<$Res> {
  factory $TagCountCopyWith(TagCount value, $Res Function(TagCount) then) =
      _$TagCountCopyWithImpl<$Res, TagCount>;
  @useResult
  $Res call({String tag, int count});
}

/// @nodoc
class _$TagCountCopyWithImpl<$Res, $Val extends TagCount>
    implements $TagCountCopyWith<$Res> {
  _$TagCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TagCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tag = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            tag: null == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TagCountImplCopyWith<$Res>
    implements $TagCountCopyWith<$Res> {
  factory _$$TagCountImplCopyWith(
    _$TagCountImpl value,
    $Res Function(_$TagCountImpl) then,
  ) = __$$TagCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String tag, int count});
}

/// @nodoc
class __$$TagCountImplCopyWithImpl<$Res>
    extends _$TagCountCopyWithImpl<$Res, _$TagCountImpl>
    implements _$$TagCountImplCopyWith<$Res> {
  __$$TagCountImplCopyWithImpl(
    _$TagCountImpl _value,
    $Res Function(_$TagCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TagCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tag = null, Object? count = null}) {
    return _then(
      _$TagCountImpl(
        tag: null == tag
            ? _value.tag
            : tag // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TagCountImpl implements _TagCount {
  const _$TagCountImpl({required this.tag, required this.count});

  factory _$TagCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagCountImplFromJson(json);

  @override
  final String tag;
  @override
  final int count;

  @override
  String toString() {
    return 'TagCount(tag: $tag, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagCountImpl &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tag, count);

  /// Create a copy of TagCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagCountImplCopyWith<_$TagCountImpl> get copyWith =>
      __$$TagCountImplCopyWithImpl<_$TagCountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagCountImplToJson(this);
  }
}

abstract class _TagCount implements TagCount {
  const factory _TagCount({
    required final String tag,
    required final int count,
  }) = _$TagCountImpl;

  factory _TagCount.fromJson(Map<String, dynamic> json) =
      _$TagCountImpl.fromJson;

  @override
  String get tag;
  @override
  int get count;

  /// Create a copy of TagCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagCountImplCopyWith<_$TagCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
