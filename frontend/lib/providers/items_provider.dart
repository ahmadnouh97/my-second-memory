import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../services/api_service.dart';
import '../widgets/filter_bar.dart';

// ── Singleton ApiService ────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// ── Items list state ────────────────────────────────────────────────────────

class ItemsState {
  const ItemsState({
    this.items = const [],
    this.availableTags = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
    this.searchQuery = '',
    this.filter = const FilterState(),
  });

  final List<Item> items;
  final List<String> availableTags;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final String searchQuery;
  final FilterState filter;

  bool get isSearching => searchQuery.isNotEmpty;

  ItemsState copyWith({
    List<Item>? items,
    List<String>? availableTags,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? Function()? error,
    int? currentPage,
    String? searchQuery,
    FilterState? filter,
  }) =>
      ItemsState(
        items: items ?? this.items,
        availableTags: availableTags ?? this.availableTags,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error != null ? error() : this.error,
        currentPage: currentPage ?? this.currentPage,
        searchQuery: searchQuery ?? this.searchQuery,
        filter: filter ?? this.filter,
      );
}

class ItemsNotifier extends StateNotifier<ItemsState> {
  ItemsNotifier(this._api) : super(const ItemsState());

  final ApiService _api;
  static const _pageSize = 20;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final resp = await _api.listItems(page: 1, limit: _pageSize);
      final tags = _extractTags(resp.items);
      state = state.copyWith(
        items: resp.items,
        availableTags: tags,
        isLoading: false,
        currentPage: 1,
        hasMore: resp.items.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: () => e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isSearching) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final resp = await _api.listItems(
        page: nextPage,
        limit: _pageSize,
        contentType: state.filter.contentType,
        tags: state.filter.selectedTags.isEmpty
            ? null
            : state.filter.selectedTags,
      );
      final newTags =
          _extractTags([...state.items, ...resp.items]);
      state = state.copyWith(
        items: [...state.items, ...resp.items],
        availableTags: newTags,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: resp.items.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      await loadInitial();
      return;
    }
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final results = await _api.searchItems(
        query,
        contentType: state.filter.contentType,
        tags: state.filter.selectedTags.isEmpty
            ? null
            : state.filter.selectedTags,
      );
      state = state.copyWith(items: results, isLoading: false, hasMore: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: () => e.toString());
    }
  }

  Future<void> applyFilter(FilterState filter) async {
    state = state.copyWith(filter: filter);
    if (state.isSearching) {
      await search(state.searchQuery);
    } else {
      state = state.copyWith(isLoading: true, error: () => null);
      try {
        final resp = await _api.listItems(
          page: 1,
          limit: _pageSize,
          contentType: filter.contentType,
          tags: filter.selectedTags.isEmpty ? null : filter.selectedTags,
        );
        state = state.copyWith(
          items: resp.items,
          isLoading: false,
          currentPage: 1,
          hasMore: resp.items.length >= _pageSize,
        );
      } catch (e) {
        state = state.copyWith(
            isLoading: false, error: () => e.toString());
      }
    }
  }

  Future<void> resetAndReload() async {
    state = const ItemsState();
    await loadInitial();
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  Future<void> deleteItem(String id) async {
    removeItem(id);
    try {
      await _api.deleteItem(id);
    } catch (_) {
      // Already removed from UI; silently fail
    }
  }

  List<String> _extractTags(List<Item> items) {
    final freq = <String, int>{};
    for (final item in items) {
      for (final tag in item.tags) {
        freq[tag] = (freq[tag] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }
}

final itemsProvider =
    StateNotifierProvider<ItemsNotifier, ItemsState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ItemsNotifier(api);
});
