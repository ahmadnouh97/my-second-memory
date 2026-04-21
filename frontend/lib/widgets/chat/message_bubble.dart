import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../models/agent_phase.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';
import '../../utils/chat_content.dart';
import '../chat_item_card.dart';
import 'markdown_bubble.dart';
import 'message_actions.dart';
import 'streaming_status.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.index,
    this.agentPhase,
    this.onRegenerate,
  });

  final ChatMessage message;
  final int index;
  /// Only meaningful when message.isStreaming == true.
  final AgentPhase? agentPhase;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final displayContent = stripItemsJson(message.content);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _AssistantAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppGradients.primary : null,
                    color: isUser ? null : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border:
                        isUser ? null : Border.all(color: AppColors.border),
                  ),
                  child: _BubbleContent(
                    message: message,
                    displayContent: displayContent,
                    isUser: isUser,
                    agentPhase: agentPhase ?? const AgentPhaseTyping(),
                  ),
                ),
              ),
            ],
          ),
          if (!isUser && !message.isStreaming && displayContent.isNotEmpty) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: MessageActions(
                content: displayContent,
                createdAt: message.createdAt,
                onRegenerate: onRegenerate,
              ),
            ),
          ],
          if (!isUser && message.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) => ChatItemCard(
                    item: message.items[i],
                    onTap: () => ctx.push('/item/${message.items[i].id}'),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: min(index, 10) * 30),
          duration: const Duration(milliseconds: 250),
        )
        .slideY(begin: 0.05, end: 0);
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.message,
    required this.displayContent,
    required this.isUser,
    required this.agentPhase,
  });

  final ChatMessage message;
  final String displayContent;
  final bool isUser;
  final AgentPhase agentPhase;

  @override
  Widget build(BuildContext context) {
    if (message.isStreaming && displayContent.isEmpty) {
      return StreamingStatusIndicator(phase: agentPhase);
    }

    if (isUser) {
      return Text(
        displayContent,
        style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownBubble(content: displayContent),
        if (message.isStreaming && agentPhase is! AgentPhaseTyping) ...[
          const SizedBox(height: 8),
          StreamingStatusIndicator(phase: agentPhase),
        ],
      ],
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.auto_awesome_rounded,
          color: Colors.white, size: 14),
    );
  }
}
