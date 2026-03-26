import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../providers/tags_provider.dart';
import '../theme/app_theme.dart';

class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key});

  @override
  ConsumerState<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends ConsumerState<TagsPage> {
  double _threshold = 0.85;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tagsProvider.notifier).loadTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tagsProvider);

    ref.listen<TagsState>(tagsProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(tagsProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(tagsProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Text('Tags'),
            if (state.tags.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.tags.length}',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        foregroundColor: AppColors.textPrimary,
      ),
      body: state.isLoadingTags
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ConsolidationSection(
                  threshold: _threshold,
                  onThresholdChanged: (v) => setState(() => _threshold = v),
                  state: state,
                ),
                const SizedBox(height: 24),
                if (state.tags.isNotEmpty) ...[
                  Text(
                    'All Tags',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.tags
                        .map((t) => _TagCountChip(tagCount: t))
                        .toList(),
                  ),
                ],
              ],
            ),
    );
  }
}

// ── Consolidation section ─────────────────────────────────────────────────────

class _ConsolidationSection extends ConsumerWidget {
  const _ConsolidationSection({
    required this.threshold,
    required this.onThresholdChanged,
    required this.state,
  });

  final double threshold;
  final ValueChanged<double> onThresholdChanged;
  final TagsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consolidate Duplicates',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find and merge semantically similar tags across all your saved items.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Sensitivity',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                threshold.toStringAsFixed(2),
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primaryLight,
              inactiveTrackColor: AppColors.border,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: threshold,
              min: 0.5,
              max: 1.0,
              divisions: 50,
              onChanged: state.preview == null ? onThresholdChanged : null,
            ),
          ),
          Row(
            children: [
              Text('More merges',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const Spacer(),
              Text('Fewer merges',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isLoadingPreview || state.isApplying
                      ? null
                      : () => ref
                          .read(tagsProvider.notifier)
                          .previewConsolidate(threshold),
                  icon: state.isLoadingPreview
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Find Duplicates'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              if (state.preview != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: state.isApplying
                      ? null
                      : () => ref.read(tagsProvider.notifier).clearPreview(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
          if (state.preview != null) ...[
            const SizedBox(height: 16),
            _PreviewResults(isApplying: state.isApplying),
          ],
        ],
      ),
    );
  }
}

// ── Preview results ───────────────────────────────────────────────────────────

class _PreviewResults extends ConsumerWidget {
  const _PreviewResults({required this.isApplying});

  final bool isApplying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(tagsProvider.select((s) => s.editableGroups));
    final preview = ref.watch(tagsProvider.select((s) => s.preview));

    if (preview == null) return const SizedBox.shrink();

    if (groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Text(
              'No duplicate tags found.',
              style: TextStyle(color: AppColors.success),
            ),
          ],
        ),
      );
    }

    final activeCount = groups.where((g) => g.willApply).length;
    final activeTagsRemoved =
        groups.where((g) => g.willApply).fold<int>(0, (s, g) => s + g.activeMerged.length);
    final tagsAfter = preview.totalTagsBefore - activeTagsRemoved;

    // Disabled when no active groups, or any active group has empty canonical
    final hasEmptyCanonical = groups.any((g) => g.willApply && g.canonical.isEmpty);
    final canApply = activeCount > 0 && !hasEmptyCanonical;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$activeCount of ${groups.length} group${groups.length == 1 ? '' : 's'} selected',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${preview.totalTagsBefore} → $tagsAfter tags',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(groups.length, (i) => _MergeGroupCard(groupIndex: i)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (isApplying || !canApply)
                ? null
                : () => ref.read(tagsProvider.notifier).applyConsolidate(),
            icon: isApplying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.merge),
            label: Text(isApplying ? 'Applying…' : 'Apply Consolidation'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ── Merge group card ──────────────────────────────────────────────────────────

class _MergeGroupCard extends ConsumerWidget {
  const _MergeGroupCard({required this.groupIndex});

  final int groupIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(
      tagsProvider.select((s) => s.editableGroups[groupIndex]),
    );
    final notifier = ref.read(tagsProvider.notifier);

    return Opacity(
      opacity: group.isEnabled ? 1.0 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: group.isEnabled,
                  onChanged: (_) => notifier.toggleGroup(groupIndex),
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _CanonicalTextField(groupIndex: groupIndex),
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.itemsAffected} item${group.itemsAffected == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: group.selectedMerged.entries
                  .map((e) => _MergeTagChip(
                        tag: e.key,
                        isSelected: e.value,
                        groupEnabled: group.isEnabled,
                        onToggle: () =>
                            notifier.toggleMergedTag(groupIndex, e.key),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Canonical text field ──────────────────────────────────────────────────────

class _CanonicalTextField extends ConsumerStatefulWidget {
  const _CanonicalTextField({required this.groupIndex});

  final int groupIndex;

  @override
  ConsumerState<_CanonicalTextField> createState() =>
      _CanonicalTextFieldState();
}

class _CanonicalTextFieldState extends ConsumerState<_CanonicalTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final group = ref.read(tagsProvider).editableGroups[widget.groupIndex];
    _controller = TextEditingController(text: group.canonical);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(
      tagsProvider.select((s) => s.editableGroups[widget.groupIndex]),
    );

    // Sync controller only when canonical was reset externally (e.g. re-preview).
    // This avoids cursor-jump on every keystroke.
    if (_controller.text != group.canonical &&
        group.canonical == group.originalCanonical) {
      _controller.text = group.canonical;
    }

    return TextField(
      controller: _controller,
      enabled: group.isEnabled,
      style: const TextStyle(
        color: AppColors.primaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        hintText: group.isRenamed ? 'suggested: ${group.originalCanonical}' : null,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      onChanged: (val) =>
          ref.read(tagsProvider.notifier).renameCanonical(widget.groupIndex, val),
    );
  }
}

// ── Merge tag chip ────────────────────────────────────────────────────────────

class _MergeTagChip extends StatelessWidget {
  const _MergeTagChip({
    required this.tag,
    required this.isSelected,
    required this.groupEnabled,
    required this.onToggle,
  });

  final String tag;
  final bool isSelected;
  final bool groupEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.error : AppColors.textMuted;
    final bgColor = isSelected
        ? AppColors.error.withValues(alpha: 0.12)
        : Colors.transparent;
    final borderColor = isSelected
        ? AppColors.error.withValues(alpha: 0.3)
        : AppColors.border;

    return GestureDetector(
      onTap: groupEnabled ? onToggle : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (groupEnabled) ...[
              SizedBox(
                width: 14,
                height: 14,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  activeColor: AppColors.error,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              tag,
              style: TextStyle(
                color: color,
                fontSize: 12,
                decoration: (!isSelected && groupEnabled)
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag count chip ────────────────────────────────────────────────────────────

class _TagCountChip extends StatelessWidget {
  const _TagCountChip({required this.tagCount});

  final TagCount tagCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagCount.tag,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${tagCount.count}',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
