import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/agent_phase.dart';
import '../models/chat_message.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/chat_storage_service.dart';
import '../utils/error_messages.dart';
import 'items_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.agentPhase = const AgentPhaseIdle(),
    this.error,
    this.lastUserPrompt,
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final AgentPhase agentPhase;
  final String? error;
  final String? lastUserPrompt;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    AgentPhase? agentPhase,
    String? Function()? error,
    String? Function()? lastUserPrompt,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isStreaming: isStreaming ?? this.isStreaming,
        agentPhase: agentPhase ?? this.agentPhase,
        error: error != null ? error() : this.error,
        lastUserPrompt:
            lastUserPrompt != null ? lastUserPrompt() : this.lastUserPrompt,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._api, this._storage) : super(const ChatState()) {
    _loadHistory();
  }

  final ApiService _api;
  final ChatStorageService _storage;
  http.Client? _activeClient;
  bool _stopping = false;
  String _accumulatedText = '';
  int _idCounter = 0;

  String _newId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${++_idCounter}';

  Future<void> _loadHistory() async {
    final saved = await _storage.load();
    if (saved.isNotEmpty && mounted) {
      state = state.copyWith(messages: saved);
    }
  }

  Future<void> sendMessage(String text) async {
    if (state.isStreaming) return;
    _stopping = false;
    _accumulatedText = '';

    final userMsg = ChatMessage(
      id: _newId(),
      role: ChatRole.user,
      content: text,
      createdAt: DateTime.now(),
    );
    final history = List<ChatMessage>.from(state.messages);
    state = state.copyWith(
      messages: [...history, userMsg],
      isStreaming: true,
      agentPhase: const AgentPhaseThinking(),
      error: () => null,
      lastUserPrompt: () => text,
    );

    final placeholder = ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    state = state.copyWith(messages: [...state.messages, placeholder]);

    _activeClient = http.Client();

    try {
      await for (final chunk
          in _api.chatStream(text, history, httpClient: _activeClient)) {
        if (_stopping) break;
        _handleChunk(chunk);
      }
    } catch (e) {
      if (!_stopping) {
        final msg = e is RateLimitException
            ? rateLimitMessage(e.service, e.retryAfter)
            : e.toString();
        state = state.copyWith(error: () => msg);
      }
    } finally {
      _activeClient?.close();
      _activeClient = null;
      _finalize(wasStopped: _stopping);
      _stopping = false;
    }
  }

  void _handleChunk(ChatChunk chunk) {
    switch (chunk) {
      case ChatChunkText(:final content):
        _accumulatedText += content;
        _updateLastMessage(content: _accumulatedText, isStreaming: true);
        state = state.copyWith(agentPhase: const AgentPhaseTyping());

      case ChatChunkItems(:final items):
        _updateLastMessage(
            content: _accumulatedText, items: items, isStreaming: true);

      case ChatChunkToolStart(:final tool):
        state = state.copyWith(agentPhase: AgentPhaseToolRunning(tool));

      case ChatChunkToolEnd():
        state = state.copyWith(agentPhase: const AgentPhaseThinking());

      case ChatChunkThinking():
        state = state.copyWith(agentPhase: const AgentPhaseThinking());

      case ChatChunkError(:final message):
        state = state.copyWith(error: () => message);

      case ChatChunkDone():
        break;
    }
  }

  void _updateLastMessage({
    required String content,
    List<Item>? items,
    required bool isStreaming,
    bool wasStopped = false,
  }) {
    if (state.messages.isEmpty) return;
    final last = state.messages.last;
    final updated = last.copyWith(
      content: content,
      items: items != null ? List.from(items) : last.items,
      isStreaming: isStreaming,
      wasStopped: wasStopped,
    );
    state = state.copyWith(
      messages: [
        ...state.messages.sublist(0, state.messages.length - 1),
        updated,
      ],
    );
  }

  void _finalize({bool wasStopped = false}) {
    if (!state.isStreaming) return;
    final content =
        state.messages.isNotEmpty ? state.messages.last.content : '';
    _updateLastMessage(
        content: content, isStreaming: false, wasStopped: wasStopped);
    state = state.copyWith(
      isStreaming: false,
      agentPhase: const AgentPhaseIdle(),
    );
    _accumulatedText = '';
    _storage.save(state.messages);
  }

  void stopGeneration() {
    if (!state.isStreaming) return;
    _stopping = true;
    _activeClient?.close();
    _activeClient = null;
  }

  Future<void> retry() async {
    if (state.isStreaming) return;
    final prompt = state.lastUserPrompt;
    if (prompt == null) return;

    var messages = List<ChatMessage>.from(state.messages);
    if (messages.isNotEmpty && messages.last.role == ChatRole.assistant) {
      messages.removeLast();
    }
    if (messages.isNotEmpty && messages.last.role == ChatRole.user) {
      messages.removeLast();
    }

    state = state.copyWith(messages: messages, error: () => null);
    await sendMessage(prompt);
  }

  void dismissError() => state = state.copyWith(error: () => null);

  Future<void> clear() async {
    state = const ChatState();
    await _storage.clear();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final chatStorageProvider =
    Provider<ChatStorageService>((_) => ChatStorageService());

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(chatStorageProvider);
  return ChatNotifier(api, storage);
});
