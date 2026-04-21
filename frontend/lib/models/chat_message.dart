import 'package:freezed_annotation/freezed_annotation.dart';
import 'item.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum ChatRole { user, assistant }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatRole role,
    required String content,
    required DateTime createdAt,
    @Default([]) List<Item> items,
    @Default(false) bool isStreaming,
    @Default(false) bool wasStopped,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// A chunk received from the SSE stream.
@freezed
class ChatChunk with _$ChatChunk {
  const factory ChatChunk.text({required String content}) = ChatChunkText;
  const factory ChatChunk.items({required List<Item> items}) = ChatChunkItems;
  const factory ChatChunk.done() = ChatChunkDone;
  const factory ChatChunk.error({required String message}) = ChatChunkError;
  const factory ChatChunk.toolStart({required String tool}) = ChatChunkToolStart;
  const factory ChatChunk.toolEnd({required String tool}) = ChatChunkToolEnd;
  const factory ChatChunk.thinking() = ChatChunkThinking;
}
