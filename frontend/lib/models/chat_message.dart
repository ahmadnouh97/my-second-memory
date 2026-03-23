import 'package:freezed_annotation/freezed_annotation.dart';
import 'item.dart';

part 'chat_message.freezed.dart';

enum ChatRole { user, assistant }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required ChatRole role,
    required String content,
    @Default([]) List<Item> items,
    @Default(false) bool isStreaming,
  }) = _ChatMessage;
}

/// A chunk received from the SSE stream.
@freezed
class ChatChunk with _$ChatChunk {
  const factory ChatChunk.text({required String content}) = ChatChunkText;
  const factory ChatChunk.items({required List<Item> items}) = ChatChunkItems;
  const factory ChatChunk.done() = ChatChunkDone;
  const factory ChatChunk.error({required String message}) = ChatChunkError;
}
