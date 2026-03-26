import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../providers/items_provider.dart';
import '../services/api_service.dart';

// ── Tags state ───────────────────────────────────────────────────────────────

class TagsState {
  const TagsState({
    this.tags = const [],
    this.preview,
    this.isLoadingTags = false,
    this.isLoadingPreview = false,
    this.isApplying = false,
    this.error,
    this.successMessage,
  });

  final List<TagCount> tags;
  final ConsolidateResponse? preview;
  final bool isLoadingTags;
  final bool isLoadingPreview;
  final bool isApplying;
  final String? error;
  final String? successMessage;

  TagsState copyWith({
    List<TagCount>? tags,
    ConsolidateResponse? Function()? preview,
    bool? isLoadingTags,
    bool? isLoadingPreview,
    bool? isApplying,
    String? Function()? error,
    String? Function()? successMessage,
  }) =>
      TagsState(
        tags: tags ?? this.tags,
        preview: preview != null ? preview() : this.preview,
        isLoadingTags: isLoadingTags ?? this.isLoadingTags,
        isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
        isApplying: isApplying ?? this.isApplying,
        error: error != null ? error() : this.error,
        successMessage: successMessage != null ? successMessage() : this.successMessage,
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class TagsNotifier extends StateNotifier<TagsState> {
  TagsNotifier(this._api, this._ref) : super(const TagsState());

  final ApiService _api;
  final Ref _ref;

  Future<void> loadTags() async {
    state = state.copyWith(
      isLoadingTags: true,
      error: () => null,
      successMessage: () => null,
    );
    try {
      final tags = await _api.getTags();
      state = state.copyWith(tags: tags, isLoadingTags: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingTags: false,
        error: () => e.toString(),
      );
    }
  }

  Future<void> previewConsolidate(double? threshold) async {
    state = state.copyWith(
      isLoadingPreview: true,
      error: () => null,
      preview: () => null,
    );
    try {
      final response = await _api.previewConsolidate(threshold: threshold);
      state = state.copyWith(preview: () => response, isLoadingPreview: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingPreview: false,
        error: () => e.toString(),
      );
    }
  }

  Future<void> applyConsolidate(double? threshold) async {
    state = state.copyWith(isApplying: true, error: () => null);
    try {
      final response = await _api.applyConsolidate(threshold: threshold);
      final mergedCount = response.groups.fold<int>(
        0,
        (sum, g) => sum + g.merged.length,
      );

      // Reload tags list to reflect consolidated state
      final freshTags = await _api.getTags();

      state = state.copyWith(
        tags: freshTags,
        preview: () => null,
        isApplying: false,
        successMessage: () => mergedCount > 0
            ? 'Merged $mergedCount tag${mergedCount == 1 ? '' : 's'} into ${response.groups.length} group${response.groups.length == 1 ? '' : 's'}.'
            : 'No duplicates found.',
      );

      // Reload items so home page reflects consolidated tags (clears stale filter state too)
      await _ref.read(itemsProvider.notifier).resetAndReload();
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        error: () => e.toString(),
      );
    }
  }

  void clearPreview() {
    state = state.copyWith(preview: () => null);
  }

  void clearMessages() {
    state = state.copyWith(
      error: () => null,
      successMessage: () => null,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final tagsProvider = StateNotifierProvider<TagsNotifier, TagsState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return TagsNotifier(api, ref);
});
