import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/item.dart';
import '../theme/app_theme.dart';
import 'tag_chip.dart';

class FilterState {
  const FilterState({
    this.contentType,
    this.selectedTags = const [],
  });

  final ContentType? contentType;
  final List<String> selectedTags;

  bool get isEmpty => contentType == null && selectedTags.isEmpty;

  FilterState copyWith({
    ContentType? Function()? contentType,
    List<String>? selectedTags,
  }) =>
      FilterState(
        contentType:
            contentType != null ? contentType() : this.contentType,
        selectedTags: selectedTags ?? this.selectedTags,
      );
}

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.state,
    required this.availableTags,
    required this.onChanged,
    this.isExpanded = false,
    this.onToggleExpanded,
  });

  final FilterState state;
  final List<String> availableTags;
  final ValueChanged<FilterState> onChanged;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            GestureDetector(
              onTap: onToggleExpanded,
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: state.isEmpty
                        ? AppColors.textMuted
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: state.isEmpty
                          ? AppColors.textMuted
                          : AppColors.primary,
                    ),
                  ),
                  if (!state.isEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(state.contentType != null ? 1 : 0) + state.selectedTags.length}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (!state.isEmpty)
              TextButton.icon(
                onPressed: () => onChanged(const FilterState()),
                icon: const Icon(Icons.close_rounded, size: 14),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  textStyle: const TextStyle(fontSize: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        // Expandable filter options
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _FilterOptions(
            state: state,
            availableTags: availableTags,
            onChanged: onChanged,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}

class _FilterOptions extends StatelessWidget {
  const _FilterOptions({
    required this.state,
    required this.availableTags,
    required this.onChanged,
  });

  final FilterState state;
  final List<String> availableTags;
  final ValueChanged<FilterState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content type row
          Text('Type',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: ContentType.values.map((t) {
              final selected = state.contentType == t;
              final (_, icon, color) = _typeData(t);
              return GestureDetector(
                onTap: () => onChanged(state.copyWith(
                    contentType: () => selected ? null : t)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.2)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          size: 13, color: selected ? color : AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        t.name[0].toUpperCase() + t.name.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              selected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 200))
              .slideY(begin: -0.05, end: 0),
          if (availableTags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Tags',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: availableTags.take(15).map((tag) {
                final selected = state.selectedTags.contains(tag);
                return TagChip(
                  label: tag,
                  selected: selected,
                  small: true,
                  onTap: () {
                    final updated = selected
                        ? state.selectedTags
                            .where((t) => t != tag)
                            .toList()
                        : [...state.selectedTags, tag];
                    onChanged(state.copyWith(selectedTags: updated));
                  },
                );
              }).toList(),
            )
                .animate()
                .fadeIn(
                    delay: const Duration(milliseconds: 50),
                    duration: const Duration(milliseconds: 200))
                .slideY(begin: -0.05, end: 0),
          ],
        ],
      ),
    );
  }

  static (String, IconData, Color) _typeData(ContentType t) =>
      switch (t) {
        ContentType.youtube =>
          ('YouTube', Icons.play_circle_outline_rounded, AppColors.youtube),
        ContentType.instagram =>
          ('Instagram', Icons.camera_alt_outlined, AppColors.instagram),
        ContentType.linkedin =>
          ('LinkedIn', Icons.work_outline_rounded, AppColors.linkedin),
        ContentType.github =>
          ('GitHub', Icons.code_rounded, AppColors.github),
        ContentType.facebook =>
          ('Facebook', Icons.people_outline_rounded, AppColors.facebook),
        ContentType.tiktok =>
          ('TikTok', Icons.music_note_outlined, AppColors.tiktok),
        ContentType.reddit =>
          ('Reddit', Icons.forum_outlined, AppColors.reddit),
        ContentType.other =>
          ('Other', Icons.link_rounded, AppColors.other),
      };
}
