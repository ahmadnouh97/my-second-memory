// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  ChatRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<Item> get items => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  bool get wasStopped => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    ChatRole role,
    String content,
    DateTime createdAt,
    List<Item> items,
    bool isStreaming,
    bool wasStopped,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
    Object? items = null,
    Object? isStreaming = null,
    Object? wasStopped = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as ChatRole,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<Item>,
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            wasStopped: null == wasStopped
                ? _value.wasStopped
                : wasStopped // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    ChatRole role,
    String content,
    DateTime createdAt,
    List<Item> items,
    bool isStreaming,
    bool wasStopped,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
    Object? items = null,
    Object? isStreaming = null,
    Object? wasStopped = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as ChatRole,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Item>,
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        wasStopped: null == wasStopped
            ? _value.wasStopped
            : wasStopped // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    final List<Item> items = const [],
    this.isStreaming = false,
    this.wasStopped = false,
  }) : _items = items;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final ChatRole role;
  @override
  final String content;
  @override
  final DateTime createdAt;
  final List<Item> _items;
  @override
  @JsonKey()
  List<Item> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final bool wasStopped;

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, content: $content, createdAt: $createdAt, items: $items, isStreaming: $isStreaming, wasStopped: $wasStopped)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.wasStopped, wasStopped) ||
                other.wasStopped == wasStopped));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    role,
    content,
    createdAt,
    const DeepCollectionEquality().hash(_items),
    isStreaming,
    wasStopped,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final ChatRole role,
    required final String content,
    required final DateTime createdAt,
    final List<Item> items,
    final bool isStreaming,
    final bool wasStopped,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  ChatRole get role;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  List<Item> get items;
  @override
  bool get isStreaming;
  @override
  bool get wasStopped;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatChunk {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatChunkCopyWith<$Res> {
  factory $ChatChunkCopyWith(ChatChunk value, $Res Function(ChatChunk) then) =
      _$ChatChunkCopyWithImpl<$Res, ChatChunk>;
}

/// @nodoc
class _$ChatChunkCopyWithImpl<$Res, $Val extends ChatChunk>
    implements $ChatChunkCopyWith<$Res> {
  _$ChatChunkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ChatChunkTextImplCopyWith<$Res> {
  factory _$$ChatChunkTextImplCopyWith(
    _$ChatChunkTextImpl value,
    $Res Function(_$ChatChunkTextImpl) then,
  ) = __$$ChatChunkTextImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$ChatChunkTextImplCopyWithImpl<$Res>
    extends _$ChatChunkCopyWithImpl<$Res, _$ChatChunkTextImpl>
    implements _$$ChatChunkTextImplCopyWith<$Res> {
  __$$ChatChunkTextImplCopyWithImpl(
    _$ChatChunkTextImpl _value,
    $Res Function(_$ChatChunkTextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null}) {
    return _then(
      _$ChatChunkTextImpl(
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatChunkTextImpl implements ChatChunkText {
  const _$ChatChunkTextImpl({required this.content});

  @override
  final String content;

  @override
  String toString() {
    return 'ChatChunk.text(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatChunkTextImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatChunkTextImplCopyWith<_$ChatChunkTextImpl> get copyWith =>
      __$$ChatChunkTextImplCopyWithImpl<_$ChatChunkTextImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) {
    return text(content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) {
    return text?.call(content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }
}

abstract class ChatChunkText implements ChatChunk {
  const factory ChatChunkText({required final String content}) =
      _$ChatChunkTextImpl;

  String get content;

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatChunkTextImplCopyWith<_$ChatChunkTextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatChunkItemsImplCopyWith<$Res> {
  factory _$$ChatChunkItemsImplCopyWith(
    _$ChatChunkItemsImpl value,
    $Res Function(_$ChatChunkItemsImpl) then,
  ) = __$$ChatChunkItemsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Item> items});
}

/// @nodoc
class __$$ChatChunkItemsImplCopyWithImpl<$Res>
    extends _$ChatChunkCopyWithImpl<$Res, _$ChatChunkItemsImpl>
    implements _$$ChatChunkItemsImplCopyWith<$Res> {
  __$$ChatChunkItemsImplCopyWithImpl(
    _$ChatChunkItemsImpl _value,
    $Res Function(_$ChatChunkItemsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _$ChatChunkItemsImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Item>,
      ),
    );
  }
}

/// @nodoc

class _$ChatChunkItemsImpl implements ChatChunkItems {
  const _$ChatChunkItemsImpl({required final List<Item> items})
    : _items = items;

  final List<Item> _items;
  @override
  List<Item> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ChatChunk.items(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatChunkItemsImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatChunkItemsImplCopyWith<_$ChatChunkItemsImpl> get copyWith =>
      __$$ChatChunkItemsImplCopyWithImpl<_$ChatChunkItemsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) {
    return items(this.items);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) {
    return items?.call(this.items);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) {
    if (items != null) {
      return items(this.items);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) {
    return items(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) {
    return items?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) {
    if (items != null) {
      return items(this);
    }
    return orElse();
  }
}

abstract class ChatChunkItems implements ChatChunk {
  const factory ChatChunkItems({required final List<Item> items}) =
      _$ChatChunkItemsImpl;

  List<Item> get items;

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatChunkItemsImplCopyWith<_$ChatChunkItemsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatChunkDoneImplCopyWith<$Res> {
  factory _$$ChatChunkDoneImplCopyWith(
    _$ChatChunkDoneImpl value,
    $Res Function(_$ChatChunkDoneImpl) then,
  ) = __$$ChatChunkDoneImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ChatChunkDoneImplCopyWithImpl<$Res>
    extends _$ChatChunkCopyWithImpl<$Res, _$ChatChunkDoneImpl>
    implements _$$ChatChunkDoneImplCopyWith<$Res> {
  __$$ChatChunkDoneImplCopyWithImpl(
    _$ChatChunkDoneImpl _value,
    $Res Function(_$ChatChunkDoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ChatChunkDoneImpl implements ChatChunkDone {
  const _$ChatChunkDoneImpl();

  @override
  String toString() {
    return 'ChatChunk.done()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ChatChunkDoneImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) {
    return done();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) {
    return done?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }
}

abstract class ChatChunkDone implements ChatChunk {
  const factory ChatChunkDone() = _$ChatChunkDoneImpl;
}

/// @nodoc
abstract class _$$ChatChunkErrorImplCopyWith<$Res> {
  factory _$$ChatChunkErrorImplCopyWith(
    _$ChatChunkErrorImpl value,
    $Res Function(_$ChatChunkErrorImpl) then,
  ) = __$$ChatChunkErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ChatChunkErrorImplCopyWithImpl<$Res>
    extends _$ChatChunkCopyWithImpl<$Res, _$ChatChunkErrorImpl>
    implements _$$ChatChunkErrorImplCopyWith<$Res> {
  __$$ChatChunkErrorImplCopyWithImpl(
    _$ChatChunkErrorImpl _value,
    $Res Function(_$ChatChunkErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ChatChunkErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatChunkErrorImpl implements ChatChunkError {
  const _$ChatChunkErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'ChatChunk.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatChunkErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatChunkErrorImplCopyWith<_$ChatChunkErrorImpl> get copyWith =>
      __$$ChatChunkErrorImplCopyWithImpl<_$ChatChunkErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ChatChunkError implements ChatChunk {
  const factory ChatChunkError({required final String message}) =
      _$ChatChunkErrorImpl;

  String get message;

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatChunkErrorImplCopyWith<_$ChatChunkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatChunkToolStartImplCopyWith<$Res> {
  factory _$$ChatChunkToolStartImplCopyWith(
    _$ChatChunkToolStartImpl value,
    $Res Function(_$ChatChunkToolStartImpl) then,
  ) = __$$ChatChunkToolStartImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String tool});
}

/// @nodoc
class __$$ChatChunkToolStartImplCopyWithImpl<$Res>
    extends _$ChatChunkCopyWithImpl<$Res, _$ChatChunkToolStartImpl>
    implements _$$ChatChunkToolStartImplCopyWith<$Res> {
  __$$ChatChunkToolStartImplCopyWithImpl(
    _$ChatChunkToolStartImpl _value,
    $Res Function(_$ChatChunkToolStartImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tool = null}) {
    return _then(
      _$ChatChunkToolStartImpl(
        tool: null == tool
            ? _value.tool
            : tool // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatChunkToolStartImpl implements ChatChunkToolStart {
  const _$ChatChunkToolStartImpl({required this.tool});

  @override
  final String tool;

  @override
  String toString() {
    return 'ChatChunk.toolStart(tool: $tool)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatChunkToolStartImpl &&
            (identical(other.tool, tool) || other.tool == tool));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tool);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatChunkToolStartImplCopyWith<_$ChatChunkToolStartImpl> get copyWith =>
      __$$ChatChunkToolStartImplCopyWithImpl<_$ChatChunkToolStartImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) {
    return toolStart(tool);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) {
    return toolStart?.call(tool);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) {
    if (toolStart != null) {
      return toolStart(tool);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) {
    return toolStart(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) {
    return toolStart?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) {
    if (toolStart != null) {
      return toolStart(this);
    }
    return orElse();
  }
}

abstract class ChatChunkToolStart implements ChatChunk {
  const factory ChatChunkToolStart({required final String tool}) =
      _$ChatChunkToolStartImpl;

  String get tool;

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatChunkToolStartImplCopyWith<_$ChatChunkToolStartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatChunkToolEndImplCopyWith<$Res> {
  factory _$$ChatChunkToolEndImplCopyWith(
    _$ChatChunkToolEndImpl value,
    $Res Function(_$ChatChunkToolEndImpl) then,
  ) = __$$ChatChunkToolEndImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String tool});
}

/// @nodoc
class __$$ChatChunkToolEndImplCopyWithImpl<$Res>
    extends _$ChatChunkCopyWithImpl<$Res, _$ChatChunkToolEndImpl>
    implements _$$ChatChunkToolEndImplCopyWith<$Res> {
  __$$ChatChunkToolEndImplCopyWithImpl(
    _$ChatChunkToolEndImpl _value,
    $Res Function(_$ChatChunkToolEndImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tool = null}) {
    return _then(
      _$ChatChunkToolEndImpl(
        tool: null == tool
            ? _value.tool
            : tool // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatChunkToolEndImpl implements ChatChunkToolEnd {
  const _$ChatChunkToolEndImpl({required this.tool});

  @override
  final String tool;

  @override
  String toString() {
    return 'ChatChunk.toolEnd(tool: $tool)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatChunkToolEndImpl &&
            (identical(other.tool, tool) || other.tool == tool));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tool);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatChunkToolEndImplCopyWith<_$ChatChunkToolEndImpl> get copyWith =>
      __$$ChatChunkToolEndImplCopyWithImpl<_$ChatChunkToolEndImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) {
    return toolEnd(tool);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) {
    return toolEnd?.call(tool);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) {
    if (toolEnd != null) {
      return toolEnd(tool);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) {
    return toolEnd(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) {
    return toolEnd?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) {
    if (toolEnd != null) {
      return toolEnd(this);
    }
    return orElse();
  }
}

abstract class ChatChunkToolEnd implements ChatChunk {
  const factory ChatChunkToolEnd({required final String tool}) =
      _$ChatChunkToolEndImpl;

  String get tool;

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatChunkToolEndImplCopyWith<_$ChatChunkToolEndImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatChunkThinkingImplCopyWith<$Res> {
  factory _$$ChatChunkThinkingImplCopyWith(
    _$ChatChunkThinkingImpl value,
    $Res Function(_$ChatChunkThinkingImpl) then,
  ) = __$$ChatChunkThinkingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ChatChunkThinkingImplCopyWithImpl<$Res>
    extends _$ChatChunkCopyWithImpl<$Res, _$ChatChunkThinkingImpl>
    implements _$$ChatChunkThinkingImplCopyWith<$Res> {
  __$$ChatChunkThinkingImplCopyWithImpl(
    _$ChatChunkThinkingImpl _value,
    $Res Function(_$ChatChunkThinkingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatChunk
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ChatChunkThinkingImpl implements ChatChunkThinking {
  const _$ChatChunkThinkingImpl();

  @override
  String toString() {
    return 'ChatChunk.thinking()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ChatChunkThinkingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String content) text,
    required TResult Function(List<Item> items) items,
    required TResult Function() done,
    required TResult Function(String message) error,
    required TResult Function(String tool) toolStart,
    required TResult Function(String tool) toolEnd,
    required TResult Function() thinking,
  }) {
    return thinking();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
    TResult? Function(String tool)? toolStart,
    TResult? Function(String tool)? toolEnd,
    TResult? Function()? thinking,
  }) {
    return thinking?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    TResult Function(String tool)? toolStart,
    TResult Function(String tool)? toolEnd,
    TResult Function()? thinking,
    required TResult orElse(),
  }) {
    if (thinking != null) {
      return thinking();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
    required TResult Function(ChatChunkToolStart value) toolStart,
    required TResult Function(ChatChunkToolEnd value) toolEnd,
    required TResult Function(ChatChunkThinking value) thinking,
  }) {
    return thinking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
    TResult? Function(ChatChunkToolStart value)? toolStart,
    TResult? Function(ChatChunkToolEnd value)? toolEnd,
    TResult? Function(ChatChunkThinking value)? thinking,
  }) {
    return thinking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
    TResult Function(ChatChunkToolStart value)? toolStart,
    TResult Function(ChatChunkToolEnd value)? toolEnd,
    TResult Function(ChatChunkThinking value)? thinking,
    required TResult orElse(),
  }) {
    if (thinking != null) {
      return thinking(this);
    }
    return orElse();
  }
}

abstract class ChatChunkThinking implements ChatChunk {
  const factory ChatChunkThinking() = _$ChatChunkThinkingImpl;
}
