import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat/chat_input_bar.dart';
import '../widgets/chat/error_banner.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/welcome_screen.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    return _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <
        80;
  }

  void _onScroll() {
    final nearBottom = _isNearBottom();
    if (_showScrollFab == nearBottom) {
      setState(() => _showScrollFab = !nearBottom);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This will permanently delete all messages.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(chatProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);

    ref.listen(chatProvider, (prev, next) {
      final grew = (next.messages.length) > (prev?.messages.length ?? 0) ||
          (next.isStreaming && next.messages.isNotEmpty);
      if (grew && _isNearBottom()) _scrollToBottom();
      if (grew && !_isNearBottom()) {
        setState(() => _showScrollFab = true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Memory Assistant'),
          ],
        ),
        actions: [
          if (state.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined,
                  color: AppColors.textMuted),
              onPressed: _confirmClear,
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty
                      ? const WelcomeScreen()
                      : ListView.builder(
                          controller: _scrollController,
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: state.messages.length,
                          itemBuilder: (ctx, i) => MessageBubble(
                            message: state.messages[i],
                            index: i,
                            agentPhase: state.agentPhase,
                            onRegenerate: (!state.isStreaming &&
                                    i == state.messages.length - 1 &&
                                    state.messages[i].role == ChatRole.assistant)
                                ? () =>
                                    ref.read(chatProvider.notifier).retry()
                                : null,
                          ),
                        ),
                ),
                if (state.error != null)
                  ErrorBanner(
                    message: state.error!,
                    onRetry: () => ref.read(chatProvider.notifier).retry(),
                    onDismiss: () =>
                        ref.read(chatProvider.notifier).dismissError(),
                  ),
                ChatInputBar(
                  controller: _controller,
                  onSend: _send,
                  onStop: () =>
                      ref.read(chatProvider.notifier).stopGeneration(),
                  isStreaming: state.isStreaming,
                ),
              ],
            ),
            if (_showScrollFab)
              Positioned(
                bottom: 80,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: () {
                    _scrollToBottom();
                    setState(() => _showScrollFab = false);
                  },
                  backgroundColor: AppColors.surfaceElevated,
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
