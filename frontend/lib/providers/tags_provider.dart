import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../providers/items_provider.dart';
import '../services/api_service.dart';

// ── Tags state ───────────────────────────────────────────────────────────────

class TagsState {
  const TagsState({
    this.tags = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  final List<TagCount> tags;
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  TagsState copyWith({
    List<TagCount>? tags,
    bool? isLoading,
    bool? isProcessing,
    String? Function()? error,
    String? Function()? successMessage,
  }) =>
      TagsState(
        tags: tags ?? this.tags,
        isLoading: isLoading ?? this.isLoading,
        isProcessing: isProcessing ?? this.isProcessing,
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
      isLoading: true,
      error: () => null,
      successMessage: () => null,
    );
    try {
      final tags = await _api.getTags();
      state = state.copyWith(tags: tags, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> renameTag(String oldTag, String newTag) async {
    state = state.copyWith(isProcessing: true, error: () => null);
    try {
      await _api.renameTag(oldTag, newTag);
      final freshTags = await _api.getTags();
      state = state.copyWith(
        tags: freshTags,
        isProcessing: false,
        successMessage: () => 'Renamed "$oldTag" to "$newTag".',
      );
      await _ref.read(itemsProvider.notifier).resetAndReload();
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: () => e.toString());
    }
  }

  Future<void> deleteTag(String tag) async {
    state = state.copyWith(isProcessing: true, error: () => null);
    try {
      await _api.deleteTag(tag);
      final freshTags = await _api.getTags();
      state = state.copyWith(
        tags: freshTags,
        isProcessing: false,
        successMessage: () => 'Deleted tag "$tag".',
      );
      await _ref.read(itemsProvider.notifier).resetAndReload();
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: () => e.toString());
    }
  }

  void clearMessages() {
    state = state.copyWith(error: () => null, successMessage: () => null);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final tagsProvider = StateNotifierProvider<TagsNotifier, TagsState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return TagsNotifier(api, ref);
});
