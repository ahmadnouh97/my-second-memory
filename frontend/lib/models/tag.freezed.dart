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

MergeGroup _$MergeGroupFromJson(Map<String, dynamic> json) {
  return _MergeGroup.fromJson(json);
}

/// @nodoc
mixin _$MergeGroup {
  String get canonical => throw _privateConstructorUsedError;
  List<String> get merged => throw _privateConstructorUsedError;
  @JsonKey(name: 'items_affected')
  int get itemsAffected => throw _privateConstructorUsedError;

  /// Serializes this MergeGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MergeGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MergeGroupCopyWith<MergeGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MergeGroupCopyWith<$Res> {
  factory $MergeGroupCopyWith(
    MergeGroup value,
    $Res Function(MergeGroup) then,
  ) = _$MergeGroupCopyWithImpl<$Res, MergeGroup>;
  @useResult
  $Res call({
    String canonical,
    List<String> merged,
    @JsonKey(name: 'items_affected') int itemsAffected,
  });
}

/// @nodoc
class _$MergeGroupCopyWithImpl<$Res, $Val extends MergeGroup>
    implements $MergeGroupCopyWith<$Res> {
  _$MergeGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MergeGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canonical = null,
    Object? merged = null,
    Object? itemsAffected = null,
  }) {
    return _then(
      _value.copyWith(
            canonical: null == canonical
                ? _value.canonical
                : canonical // ignore: cast_nullable_to_non_nullable
                      as String,
            merged: null == merged
                ? _value.merged
                : merged // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            itemsAffected: null == itemsAffected
                ? _value.itemsAffected
                : itemsAffected // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MergeGroupImplCopyWith<$Res>
    implements $MergeGroupCopyWith<$Res> {
  factory _$$MergeGroupImplCopyWith(
    _$MergeGroupImpl value,
    $Res Function(_$MergeGroupImpl) then,
  ) = __$$MergeGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String canonical,
    List<String> merged,
    @JsonKey(name: 'items_affected') int itemsAffected,
  });
}

/// @nodoc
class __$$MergeGroupImplCopyWithImpl<$Res>
    extends _$MergeGroupCopyWithImpl<$Res, _$MergeGroupImpl>
    implements _$$MergeGroupImplCopyWith<$Res> {
  __$$MergeGroupImplCopyWithImpl(
    _$MergeGroupImpl _value,
    $Res Function(_$MergeGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MergeGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canonical = null,
    Object? merged = null,
    Object? itemsAffected = null,
  }) {
    return _then(
      _$MergeGroupImpl(
        canonical: null == canonical
            ? _value.canonical
            : canonical // ignore: cast_nullable_to_non_nullable
                  as String,
        merged: null == merged
            ? _value._merged
            : merged // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        itemsAffected: null == itemsAffected
            ? _value.itemsAffected
            : itemsAffected // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MergeGroupImpl implements _MergeGroup {
  const _$MergeGroupImpl({
    required this.canonical,
    required final List<String> merged,
    @JsonKey(name: 'items_affected') required this.itemsAffected,
  }) : _merged = merged;

  factory _$MergeGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$MergeGroupImplFromJson(json);

  @override
  final String canonical;
  final List<String> _merged;
  @override
  List<String> get merged {
    if (_merged is EqualUnmodifiableListView) return _merged;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_merged);
  }

  @override
  @JsonKey(name: 'items_affected')
  final int itemsAffected;

  @override
  String toString() {
    return 'MergeGroup(canonical: $canonical, merged: $merged, itemsAffected: $itemsAffected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MergeGroupImpl &&
            (identical(other.canonical, canonical) ||
                other.canonical == canonical) &&
            const DeepCollectionEquality().equals(other._merged, _merged) &&
            (identical(other.itemsAffected, itemsAffected) ||
                other.itemsAffected == itemsAffected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    canonical,
    const DeepCollectionEquality().hash(_merged),
    itemsAffected,
  );

  /// Create a copy of MergeGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MergeGroupImplCopyWith<_$MergeGroupImpl> get copyWith =>
      __$$MergeGroupImplCopyWithImpl<_$MergeGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MergeGroupImplToJson(this);
  }
}

abstract class _MergeGroup implements MergeGroup {
  const factory _MergeGroup({
    required final String canonical,
    required final List<String> merged,
    @JsonKey(name: 'items_affected') required final int itemsAffected,
  }) = _$MergeGroupImpl;

  factory _MergeGroup.fromJson(Map<String, dynamic> json) =
      _$MergeGroupImpl.fromJson;

  @override
  String get canonical;
  @override
  List<String> get merged;
  @override
  @JsonKey(name: 'items_affected')
  int get itemsAffected;

  /// Create a copy of MergeGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MergeGroupImplCopyWith<_$MergeGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConsolidateResponse _$ConsolidateResponseFromJson(Map<String, dynamic> json) {
  return _ConsolidateResponse.fromJson(json);
}

/// @nodoc
mixin _$ConsolidateResponse {
  List<MergeGroup> get groups => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_tags_before')
  int get totalTagsBefore => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_tags_after')
  int get totalTagsAfter => throw _privateConstructorUsedError;

  /// Serializes this ConsolidateResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsolidateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsolidateResponseCopyWith<ConsolidateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsolidateResponseCopyWith<$Res> {
  factory $ConsolidateResponseCopyWith(
    ConsolidateResponse value,
    $Res Function(ConsolidateResponse) then,
  ) = _$ConsolidateResponseCopyWithImpl<$Res, ConsolidateResponse>;
  @useResult
  $Res call({
    List<MergeGroup> groups,
    @JsonKey(name: 'total_tags_before') int totalTagsBefore,
    @JsonKey(name: 'total_tags_after') int totalTagsAfter,
  });
}

/// @nodoc
class _$ConsolidateResponseCopyWithImpl<$Res, $Val extends ConsolidateResponse>
    implements $ConsolidateResponseCopyWith<$Res> {
  _$ConsolidateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsolidateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groups = null,
    Object? totalTagsBefore = null,
    Object? totalTagsAfter = null,
  }) {
    return _then(
      _value.copyWith(
            groups: null == groups
                ? _value.groups
                : groups // ignore: cast_nullable_to_non_nullable
                      as List<MergeGroup>,
            totalTagsBefore: null == totalTagsBefore
                ? _value.totalTagsBefore
                : totalTagsBefore // ignore: cast_nullable_to_non_nullable
                      as int,
            totalTagsAfter: null == totalTagsAfter
                ? _value.totalTagsAfter
                : totalTagsAfter // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConsolidateResponseImplCopyWith<$Res>
    implements $ConsolidateResponseCopyWith<$Res> {
  factory _$$ConsolidateResponseImplCopyWith(
    _$ConsolidateResponseImpl value,
    $Res Function(_$ConsolidateResponseImpl) then,
  ) = __$$ConsolidateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MergeGroup> groups,
    @JsonKey(name: 'total_tags_before') int totalTagsBefore,
    @JsonKey(name: 'total_tags_after') int totalTagsAfter,
  });
}

/// @nodoc
class __$$ConsolidateResponseImplCopyWithImpl<$Res>
    extends _$ConsolidateResponseCopyWithImpl<$Res, _$ConsolidateResponseImpl>
    implements _$$ConsolidateResponseImplCopyWith<$Res> {
  __$$ConsolidateResponseImplCopyWithImpl(
    _$ConsolidateResponseImpl _value,
    $Res Function(_$ConsolidateResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConsolidateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groups = null,
    Object? totalTagsBefore = null,
    Object? totalTagsAfter = null,
  }) {
    return _then(
      _$ConsolidateResponseImpl(
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<MergeGroup>,
        totalTagsBefore: null == totalTagsBefore
            ? _value.totalTagsBefore
            : totalTagsBefore // ignore: cast_nullable_to_non_nullable
                  as int,
        totalTagsAfter: null == totalTagsAfter
            ? _value.totalTagsAfter
            : totalTagsAfter // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsolidateResponseImpl implements _ConsolidateResponse {
  const _$ConsolidateResponseImpl({
    required final List<MergeGroup> groups,
    @JsonKey(name: 'total_tags_before') required this.totalTagsBefore,
    @JsonKey(name: 'total_tags_after') required this.totalTagsAfter,
  }) : _groups = groups;

  factory _$ConsolidateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsolidateResponseImplFromJson(json);

  final List<MergeGroup> _groups;
  @override
  List<MergeGroup> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @override
  @JsonKey(name: 'total_tags_before')
  final int totalTagsBefore;
  @override
  @JsonKey(name: 'total_tags_after')
  final int totalTagsAfter;

  @override
  String toString() {
    return 'ConsolidateResponse(groups: $groups, totalTagsBefore: $totalTagsBefore, totalTagsAfter: $totalTagsAfter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsolidateResponseImpl &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            (identical(other.totalTagsBefore, totalTagsBefore) ||
                other.totalTagsBefore == totalTagsBefore) &&
            (identical(other.totalTagsAfter, totalTagsAfter) ||
                other.totalTagsAfter == totalTagsAfter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_groups),
    totalTagsBefore,
    totalTagsAfter,
  );

  /// Create a copy of ConsolidateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsolidateResponseImplCopyWith<_$ConsolidateResponseImpl> get copyWith =>
      __$$ConsolidateResponseImplCopyWithImpl<_$ConsolidateResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsolidateResponseImplToJson(this);
  }
}

abstract class _ConsolidateResponse implements ConsolidateResponse {
  const factory _ConsolidateResponse({
    required final List<MergeGroup> groups,
    @JsonKey(name: 'total_tags_before') required final int totalTagsBefore,
    @JsonKey(name: 'total_tags_after') required final int totalTagsAfter,
  }) = _$ConsolidateResponseImpl;

  factory _ConsolidateResponse.fromJson(Map<String, dynamic> json) =
      _$ConsolidateResponseImpl.fromJson;

  @override
  List<MergeGroup> get groups;
  @override
  @JsonKey(name: 'total_tags_before')
  int get totalTagsBefore;
  @override
  @JsonKey(name: 'total_tags_after')
  int get totalTagsAfter;

  /// Create a copy of ConsolidateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsolidateResponseImplCopyWith<_$ConsolidateResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
