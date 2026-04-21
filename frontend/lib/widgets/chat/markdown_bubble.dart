import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

class MarkdownBubble extends StatelessWidget {
  const MarkdownBubble({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.55),
        strong: const TextStyle(
          fontSize: 14, color: AppColors.textPrimary,
          fontWeight: FontWeight.w600, height: 1.55,
        ),
        em: const TextStyle(
          fontSize: 14, color: AppColors.textPrimary,
          fontStyle: FontStyle.italic, height: 1.55,
        ),
        code: TextStyle(
          fontSize: 13,
          color: AppColors.primaryLight,
          backgroundColor: AppColors.background.withValues(alpha: 0.7),
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquoteDecoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        blockquote: const TextStyle(
          fontSize: 14, color: AppColors.textSecondary, height: 1.55,
        ),
        listBullet: const TextStyle(
          fontSize: 14, color: AppColors.textPrimary, height: 1.55,
        ),
        h1: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        h2: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        h3: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        a: const TextStyle(
          color: AppColors.primaryLight,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primaryLight,
        ),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
      ),
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }
}
