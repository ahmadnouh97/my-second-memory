import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/editable_group.dart';
import '../models/tag.dart';
import '../providers/items_provider.dart';
import '../services/api_service.dart';

// ── Tags state ───────────────────────────────────────────────────────────────

class TagsState {
  const TagsState({
    this.tags = const [],
    this.preview,
    this.editableGroups = const [],
    this.isLoadingTags = false,
    this.isLoadingPreview = false,
    this.isApplying = false,
    this.error,
    this.successMessage,
  });

  final List<TagCount> tags;
  final ConsolidateResponse? preview;
  final List<EditableGroup> editableGroups;
  final bool isLoadingTags;
  final bool isLoadingPreview;
  final bool isApplying;
  final String? error;
  final String? successMessage;

  TagsState copyWith({
    List<TagCount>? tags,
    ConsolidateResponse? Function()? preview,
    List<EditableGroup>? editableGroups,
    bool? isLoadingTags,
    bool? isLoadingPreview,
    bool? isApplying,
    String? Function()? error,
    String? Function()? successMessage,
  }) =>
      TagsState(
        tags: tags ?? this.tags,
        preview: preview != null ? preview() : this.preview,
        editableGroups: editableGroups ?? this.editableGroups,
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

  void _initEditableGroups(ConsolidateResponse response) {
    final groups = response.groups.map((g) {
      return EditableGroup(
        originalCanonical: g.canonical,
        canonical: g.canonical,
        selectedMerged: {for (final tag in g.merged) tag: true},
        isEnabled: true,
        itemsAffected: g.itemsAffected,
      );
    }).toList();
    state = state.copyWith(editableGroups: groups);
  }

  void toggleGroup(int index) {
    final groups = List<EditableGroup>.from(state.editableGroups);
    groups[index] = groups[index].copyWith(isEnabled: !groups[index].isEnabled);
    state = state.copyWith(editableGroups: groups);
  }

  void renameCanonical(int index, String newName) {
    final trimmed = newName.trim();
    final groups = List<EditableGroup>.from(state.editableGroups);
    groups[index] = groups[index].copyWith(canonical: trimmed);
    state = state.copyWith(editableGroups: groups);
  }

  void toggleMergedTag(int groupIndex, String tag) {
    final groups = List<EditableGroup>.from(state.editableGroups);
    final group = groups[groupIndex];
    final updated = Map<String, bool>.from(group.selectedMerged);
    updated[tag] = !(updated[tag] ?? true);
    groups[groupIndex] = group.copyWith(selectedMerged: updated);
    state = state.copyWith(editableGroups: groups);
  }

  Future<void> previewConsolidate(double? threshold) async {
    state = state.copyWith(
      isLoadingPreview: true,
      error: () => null,
      preview: () => null,
      editableGroups: const [],
    );
    try {
      final response = await _api.previewConsolidate(threshold: threshold);
      state = state.copyWith(preview: () => response, isLoadingPreview: false);
      _initEditableGroups(response);
    } catch (e) {
      state = state.copyWith(
        isLoadingPreview: false,
        error: () => e.toString(),
      );
    }
  }

  Future<void> applyConsolidate() async {
    final activeGroups =
        state.editableGroups.where((g) => g.willApply).toList();
    if (activeGroups.isEmpty) return;

    state = state.copyWith(isApplying: true, error: () => null);
    try {
      final response = await _api.applyConsolidate(groups: activeGroups);
      final mergedCount = response.groups.fold<int>(
        0,
        (sum, g) => sum + g.merged.length,
      );

      // Reload tags list to reflect consolidated state
      final freshTags = await _api.getTags();

      state = state.copyWith(
        tags: freshTags,
        preview: () => null,
        editableGroups: const [],
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
    state = state.copyWith(preview: () => null, editableGroups: const []);
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
