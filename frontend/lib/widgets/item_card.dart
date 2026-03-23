import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/item.dart';
import '../theme/app_theme.dart';
import 'content_type_badge.dart';
import 'tag_chip.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.animationIndex = 0,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    final accentColor = ContentTypeBadge.colorFor(item.contentType);

    return Animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: animationIndex * 50),
          duration: const Duration(milliseconds: 300),
        ),
        SlideEffect(
          delay: Duration(milliseconds: animationIndex * 50),
          duration: const Duration(milliseconds: 300),
          begin: const Offset(0, 0.06),
          end: Offset.zero,
          curve: Curves.easeOut,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.cardGlass(accentColor),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
                child: SizedBox(
                  width: 110,
                  height: 130,
                  child: item.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: item.thumbnailUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _thumbnailPlaceholder(accentColor),
                          errorWidget: (_, __, ___) => _thumbnailPlaceholder(accentColor),
                        )
                      : _thumbnailPlaceholder(accentColor),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge + delete row
                      Row(
                        children: [
                          ContentTypeBadge(type: item.contentType, small: true),
                          const Spacer(),
                          _DeleteButton(onDelete: onDelete),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      if (item.summary != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Tags (max 3)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: item.tags
                            .take(3)
                            .map((t) => TagChip(label: t, small: true))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder(Color accent) {
    return Container(
      color: accent.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          _placeholderIcon(item.contentType),
          color: accent.withValues(alpha: 0.4),
          size: 32,
        ),
      ),
    );
  }

  IconData _placeholderIcon(ContentType type) => switch (type) {
        ContentType.youtube => Icons.play_circle_outline_rounded,
        ContentType.instagram => Icons.camera_alt_outlined,
        ContentType.article => Icons.article_outlined,
        ContentType.link => Icons.link_rounded,
      };
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            size: 15, color: AppColors.error),
      ),
    );
  }
}
