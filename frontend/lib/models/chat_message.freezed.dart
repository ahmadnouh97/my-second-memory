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

/// @nodoc
mixin _$ChatMessage {
  ChatRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<Item> get items => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;

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
    ChatRole role,
    String content,
    List<Item> items,
    bool isStreaming,
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
    Object? role = null,
    Object? content = null,
    Object? items = null,
    Object? isStreaming = null,
  }) {
    return _then(
      _value.copyWith(
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as ChatRole,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<Item>,
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
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
    ChatRole role,
    String content,
    List<Item> items,
    bool isStreaming,
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
    Object? role = null,
    Object? content = null,
    Object? items = null,
    Object? isStreaming = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as ChatRole,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Item>,
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.role,
    required this.content,
    final List<Item> items = const [],
    this.isStreaming = false,
  }) : _items = items;

  @override
  final ChatRole role;
  @override
  final String content;
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
  String toString() {
    return 'ChatMessage(role: $role, content: $content, items: $items, isStreaming: $isStreaming)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    role,
    content,
    const DeepCollectionEquality().hash(_items),
    isStreaming,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final ChatRole role,
    required final String content,
    final List<Item> items,
    final bool isStreaming,
  }) = _$ChatMessageImpl;

  @override
  ChatRole get role;
  @override
  String get content;
  @override
  List<Item> get items;
  @override
  bool get isStreaming;

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
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String content)? text,
    TResult? Function(List<Item> items)? items,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String content)? text,
    TResult Function(List<Item> items)? items,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatChunkText value) text,
    required TResult Function(ChatChunkItems value) items,
    required TResult Function(ChatChunkDone value) done,
    required TResult Function(ChatChunkError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatChunkText value)? text,
    TResult? Function(ChatChunkItems value)? items,
    TResult? Function(ChatChunkDone value)? done,
    TResult? Function(ChatChunkError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatChunkText value)? text,
    TResult Function(ChatChunkItems value)? items,
    TResult Function(ChatChunkDone value)? done,
    TResult Function(ChatChunkError value)? error,
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
