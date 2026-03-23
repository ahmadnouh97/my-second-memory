import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../providers/items_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_bar.dart';
import '../widgets/item_card.dart';
import '../widgets/shimmer_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  bool _filterExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itemsProvider.notifier).loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(itemsProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(itemsProvider.notifier).search(q);
    });
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    await ref.read(itemsProvider.notifier).loadInitial();
  }

  Future<void> _confirmDelete(String id, String title) async {
    HapticFeedback.lightImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(
          'Remove "$title" from your memory?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(itemsProvider.notifier).deleteItem(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from memory'),
          action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor: AppColors.primary),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceElevated,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/logo.svg',
                            width: 36, height: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Second Memory',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge),
                              Text(
                                '${state.items.length} items saved',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary, size: 24),
                          onPressed: () => context.push('/chat'),
                          tooltip: 'Memory Assistant',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
                ),
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search your memory...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textMuted, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: AppColors.textMuted, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(itemsProvider.notifier)
                                      .search('');
                                },
                              )
                            : null,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 300))
                      .slideY(begin: 0.05, end: 0),
                ),
                // Filter bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: FilterBar(
                      state: state.filter,
                      availableTags: state.availableTags,
                      isExpanded: _filterExpanded,
                      onToggleExpanded: () =>
                          setState(() => _filterExpanded = !_filterExpanded),
                      onChanged: (f) {
                        ref.read(itemsProvider.notifier).applyFilter(f);
                      },
                    ),
                  ),
                ),
                // Content
                if (state.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: ShimmerList(count: 5),
                    ),
                  )
                else if (state.error != null)
                  SliverToBoxAdapter(child: _ErrorState(state.error!))
                else if (state.items.isEmpty)
                  SliverToBoxAdapter(
                      child: _EmptyState(
                          isSearching: state.isSearching,
                          searchQuery: state.searchQuery))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final item = state.items[i];
                        return ItemCard(
                          key: ValueKey(item.id),
                          item: item,
                          animationIndex: i,
                          onTap: () => context.push('/item/${item.id}'),
                          onDelete: () => _confirmDelete(item.id, item.title),
                        );
                      },
                    ),
                  ),
                // Load more indicator
                if (state.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-item'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Save URL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      )
          .animate()
          .scale(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching, required this.searchQuery});
  final bool isSearching;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.bookmark_border_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No results found' : 'Your memory is empty',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try different keywords or clear filters'
                : 'Save your first URL to get started',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: const Duration(milliseconds: 400)).scale(begin: const Offset(0.95, 0.95)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState(this.error);
  final String error;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Failed to load items',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(error,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
