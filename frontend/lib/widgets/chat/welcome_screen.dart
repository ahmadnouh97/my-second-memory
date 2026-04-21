import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chat_provider.dart';
import '../../providers/tags_provider.dart';
import '../../theme/app_theme.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  List<String> _buildSuggestions(List<String> topTags) {
    final personalized = topTags.take(2).map((t) => 'Find my $t saves').toList();
    final defaults = [
      'What did I save recently?',
      'Show my YouTube videos',
      'Summarize my reading list',
      'Find articles about AI',
    ];
    // Interleave personalized + defaults, deduplicate, cap at 4
    final combined = [...personalized, ...defaults];
    final seen = <String>{};
    return combined.where((s) => seen.add(s)).take(4).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsState = ref.watch(tagsProvider);
    // Trigger load if tags haven't been fetched yet
    if (tagsState.tags.isEmpty && !tagsState.isLoading) {
      Future.microtask(() => ref.read(tagsProvider.notifier).loadTags());
    }
    final topTags = tagsState.tags.take(3).map((t) => t.tag).toList();
    final suggestions = _buildSuggestions(topTags);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 48, color: AppColors.primary),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 24),
            Text('Memory Assistant',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
            Text(
              'Ask me anything about your saved content.\nI can search, summarize, and find connections.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((s) => _SuggestionChip(text: s))
                  .toList(),
            ),
          ],
        ),
      ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(
            begin: const Offset(0.95, 0.95),
          ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  const _SuggestionChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(chatProvider.notifier).sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
