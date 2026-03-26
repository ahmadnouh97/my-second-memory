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
                  color: AppColors.primary.withValues(alpha:0.2),
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
              overlayColor: AppColors.primary.withValues(alpha:0.15),
            ),
            child: Slider(
              value: threshold,
              min: 0.5,
              max: 1.0,
              divisions: 50,
              onChanged: onThresholdChanged,
            ),
          ),
          Row(
            children: [
              Text('More merges', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const Spacer(),
              Text('Fewer merges', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
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
            const SizedBox(height: 16),
            _PreviewResults(
              preview: state.preview!,
              isApplying: state.isApplying,
              onApply: () =>
                  ref.read(tagsProvider.notifier).applyConsolidate(threshold),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Preview results ───────────────────────────────────────────────────────────

class _PreviewResults extends StatelessWidget {
  const _PreviewResults({
    required this.preview,
    required this.isApplying,
    required this.onApply,
  });

  final ConsolidateResponse preview;
  final bool isApplying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    if (preview.groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withValues(alpha:0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            const Text(
              'No duplicate tags found.',
              style: TextStyle(color: AppColors.success),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${preview.groups.length} group${preview.groups.length == 1 ? '' : 's'} found',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${preview.totalTagsBefore} → ${preview.totalTagsAfter} tags',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...preview.groups.map((g) => _MergeGroupCard(group: g)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isApplying ? null : onApply,
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

class _MergeGroupCard extends StatelessWidget {
  const _MergeGroupCard({required this.group});

  final MergeGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Icon(Icons.label, color: AppColors.primaryLight, size: 16),
              const SizedBox(width: 6),
              Text(
                group.canonical,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${group.itemsAffected} item${group.itemsAffected == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              const Text(
                'merges:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              ...group.merged.map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.error.withValues(alpha:0.3)),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
              color: AppColors.primary.withValues(alpha:0.2),
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
