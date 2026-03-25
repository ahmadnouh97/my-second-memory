import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/item.dart';
import '../providers/items_provider.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';
import '../widgets/content_type_badge.dart';
import '../widgets/tag_chip.dart';

class ItemDetailPage extends ConsumerStatefulWidget {
  const ItemDetailPage({super.key, required this.itemId});
  final String itemId;

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  Item? _item;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _tagController = TextEditingController();
  List<String> _editTags = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiServiceProvider);
      final item = await api.getItem(widget.itemId);
      if (mounted) {
        setState(() {
          _item = item;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) context.go('/home');
    }
  }

  void _startEdit() {
    setState(() {
      _editing = true;
      _titleController.text = _item!.title;
      _summaryController.text = _item!.summary ?? '';
      _editTags = List.from(_item!.tags);
    });
  }

  void _cancelEdit() => setState(() => _editing = false);

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final api = ref.read(apiServiceProvider);
      final updated = await api.updateItem(
        widget.itemId,
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim().isEmpty
            ? null
            : _summaryController.text.trim(),
        tags: _editTags,
      );
      setState(() {
        _item = updated;
        _editing = false;
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This will permanently remove the item.',
            style: TextStyle(color: AppColors.textSecondary)),
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
      ref.read(itemsProvider.notifier).removeItem(widget.itemId);
      await ref.read(apiServiceProvider).deleteItem(widget.itemId);
      if (mounted) context.go('/home');
    }
  }

  Future<void> _openUrl() async {
    if (_item == null) return;
    final uri = Uri.parse(_item!.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_editTags.contains(tag)) {
      setState(() {
        _editTags = [..._editTags, tag];
        _tagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final item = _item!;
    final accent = ContentTypeBadge.colorFor(item.contentType);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: CustomScrollView(
          slivers: [
            // Flexible app bar with hero image
            SliverAppBar(
              expandedHeight: item.thumbnailUrl != null ? 260 : 120,
              pinned: true,
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              actions: [
                if (!_editing) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.textPrimary),
                    onPressed: _startEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                    onPressed: _delete,
                    tooltip: 'Delete',
                  ),
                ],
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: item.thumbnailUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: proxyImageUrl(item.thumbnailUrl!),
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.background.withValues(alpha: 0.9),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: accent.withValues(alpha: 0.08),
                        child: Center(
                          child: Icon(Icons.bookmark_rounded,
                              size: 48, color: accent.withValues(alpha: 0.3)),
                        ),
                      ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _editing ? _buildEditMode(item) : _buildViewMode(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode(Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge + date
        Row(
          children: [
            ContentTypeBadge(type: item.contentType),
            const Spacer(),
            Text(
              _formatDate(item.createdAt),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Title
        Text(item.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                  height: 1.3,
                )),
        if (item.summary != null) ...[
          const SizedBox(height: 14),
          Text(item.summary!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  )),
        ],
        // Tags
        if (item.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                item.tags.map((t) => TagChip(label: t)).toList(),
          ),
        ],
        const SizedBox(height: 24),
        // Open URL button
        ElevatedButton.icon(
          onPressed: _openUrl,
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('Open URL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 60),
      ],
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: 0.04, end: 0);
  }

  Widget _buildEditMode(Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        _label('Title'),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Title'),
        ),
        const SizedBox(height: 14),
        // Summary
        _label('Summary'),
        const SizedBox(height: 6),
        TextField(
          controller: _summaryController,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Summary'),
        ),
        const SizedBox(height: 14),
        // Tags
        _label('Tags'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Add a tag...', isDense: true),
                onSubmitted: (_) => _addTag(),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addTag,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12)),
              child: const Text('Add'),
            ),
          ],
        ),
        if (_editTags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _editTags
                .map((t) => TagChip(
                      label: t,
                      onDelete: () => setState(
                          () => _editTags = _editTags.where((x) => x != t).toList()),
                    ))
                .toList(),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.error, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : _cancelEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(_saving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 200));
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.5));

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
