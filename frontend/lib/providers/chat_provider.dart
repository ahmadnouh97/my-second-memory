import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';
import 'items_provider.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? Function()? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isStreaming: isStreaming ?? this.isStreaming,
        error: error != null ? error() : this.error,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._api) : super(const ChatState());

  final ApiService _api;

  Future<void> sendMessage(String text) async {
    if (state.isStreaming) return;

    // Add user message
    final userMsg = ChatMessage(role: ChatRole.user, content: text);
    final history = List<ChatMessage>.from(state.messages);
    state = state.copyWith(
      messages: [...history, userMsg],
      isStreaming: true,
      error: () => null,
    );

    // Placeholder assistant message (streaming)
    final placeholder = const ChatMessage(
      role: ChatRole.assistant,
      content: '',
      isStreaming: true,
    );
    state = state.copyWith(
        messages: [...state.messages, placeholder]);

    String accumulatedText = '';

    try {
      await for (final chunk in _api.chatStream(text, history)) {
        switch (chunk) {
          case ChatChunkText(:final content):
            accumulatedText += content;
            state = state.copyWith(
              messages: [
                ...state.messages.sublist(0, state.messages.length - 1),
                ChatMessage(
                  role: ChatRole.assistant,
                  content: accumulatedText,
                  isStreaming: true,
                ),
              ],
            );
          case ChatChunkItems(:final items):
            state = state.copyWith(
              messages: [
                ...state.messages.sublist(0, state.messages.length - 1),
                ChatMessage(
                  role: ChatRole.assistant,
                  content: accumulatedText,
                  items: items,
                  isStreaming: true,
                ),
              ],
            );
          case ChatChunkDone():
            break;
          case ChatChunkError(:final message):
            state = state.copyWith(error: () => message);
            break;
        }
      }
    } catch (e) {
      final msg = e is RateLimitException
          ? rateLimitMessage(e.service, e.retryAfter)
          : e.toString();
      state = state.copyWith(error: () => msg);
    } finally {
      // Mark last message as done
      if (state.messages.isNotEmpty) {
        final last = state.messages.last;
        state = state.copyWith(
          messages: [
            ...state.messages.sublist(0, state.messages.length - 1),
            last.copyWith(isStreaming: false),
          ],
          isStreaming: false,
        );
      }
    }
  }

  void clear() => state = const ChatState();
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ChatNotifier(api);
});
