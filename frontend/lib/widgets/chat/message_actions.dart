import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../utils/time_format.dart';

class MessageActions extends StatelessWidget {
  const MessageActions({
    super.key,
    required this.content,
    required this.createdAt,
    this.onRegenerate,
  });

  final String content;
  final DateTime createdAt;
  final VoidCallback? onRegenerate;

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatRelativeTime(createdAt),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(width: 6),
          _TinyButton(
            icon: Icons.copy_rounded,
            tooltip: 'Copy',
            onTap: () => _copy(context),
          ),
          if (onRegenerate != null) ...[
            const SizedBox(width: 2),
            _TinyButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Regenerate',
              onTap: onRegenerate!,
            ),
          ],
        ],
      ),
    );
  }
}

class _TinyButton extends StatelessWidget {
  const _TinyButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 14, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
