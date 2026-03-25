import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/item.dart';
import '../providers/items_provider.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';
import '../widgets/content_type_badge.dart';
import '../widgets/tag_chip.dart';

enum _AddState { idle, extracting, preview, saving }

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key, this.initialUrl});
  final String? initialUrl;

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _tagController = TextEditingController();

  _AddState _state = _AddState.idle;
  ExtractPreview? _preview;
  String? _error;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _extract());
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  Future<void> _extract() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _state = _AddState.extracting;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final preview = await api.extractUrl(url);
      setState(() {
        _preview = preview;
        _titleController.text = preview.title;
        _summaryController.text = preview.summary ?? '';
        _tags = List.from(preview.tags);
        _state = _AddState.preview;
      });
    } catch (e) {
      setState(() {
        _state = _AddState.idle;
        _error = e.toString().replaceFirst('ApiException', '').trim();
      });
    }
  }

  Future<void> _save() async {
    if (_preview == null) return;
    setState(() => _state = _AddState.saving);
    try {
      final api = ref.read(apiServiceProvider);
      await api.createItem(
        url: _preview!.url,
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim().isEmpty
            ? null
            : _summaryController.text.trim(),
        contentType: _preview!.contentType,
        tags: _tags,
        thumbnailUrl: _preview!.thumbnailUrl,
      );
      // Reload home list and pop
      await ref.read(itemsProvider.notifier).loadInitial();
      if (mounted) {
        HapticFeedback.mediumImpact();
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _state = _AddState.preview;
        _error = e.toString().replaceFirst('ApiException', '').trim();
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags = [..._tags, tag];
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags = _tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Save to Memory'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // URL input
                _UrlInputCard(
                  controller: _urlController,
                  onExtract: _state == _AddState.idle ? _extract : null,
                  onPaste: _pasteFromClipboard,
                  isExtracting: _state == _AddState.extracting,
                  enabled: _state == _AddState.idle,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _ErrorBanner(_error!),
                ],
                // Preview
                if (_state == _AddState.extracting) ...[
                  const SizedBox(height: 24),
                  _ExtractionLoader(),
                ],
                if (_state == _AddState.preview || _state == _AddState.saving)
                  _buildPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        // Thumbnail
        if (_preview?.thumbnailUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: proxyImageUrl(_preview!.thumbnailUrl!),
              height: 180,
              fit: BoxFit.cover,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 350))
              .scale(begin: const Offset(0.97, 0.97)),
        const SizedBox(height: 16),
        // Type badge
        if (_preview != null)
          Align(
            alignment: Alignment.centerLeft,
            child: ContentTypeBadge(type: _preview!.contentType),
          ),
        const SizedBox(height: 14),
        // Title
        _buildLabel('Title'),
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
        _buildLabel('Summary'),
        const SizedBox(height: 6),
        TextField(
          controller: _summaryController,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Summary'),
        ),
        const SizedBox(height: 14),
        // Tags
        _buildLabel('Tags'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
                      horizontal: 16, vertical: 12)),
              child: const Text('Add'),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _tags
                .map((t) => TagChip(
                      label: t,
                      onDelete: () => _removeTag(t),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 28),
        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _state == _AddState.saving
                    ? null
                    : () => setState(() {
                          _state = _AddState.idle;
                          _preview = null;
                          _error = null;
                        }),
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
                onPressed:
                    _state == _AddState.saving ? null : _save,
                icon: _state == _AddState.saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.bookmark_add_rounded, size: 18),
                label: Text(_state == _AddState.saving
                    ? 'Saving...'
                    : 'Save to Memory'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: 0.04, end: 0);
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5));
  }
}

class _UrlInputCard extends StatelessWidget {
  const _UrlInputCard({
    required this.controller,
    required this.onExtract,
    required this.onPaste,
    required this.isExtracting,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback? onExtract;
  final VoidCallback onPaste;
  final bool isExtracting;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Paste a URL',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  autofocus: true,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'https://...',
                    isDense: true,
                  ),
                  onSubmitted: (_) => onExtract?.call(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.content_paste_rounded,
                    color: AppColors.textMuted),
                onPressed: onPaste,
                tooltip: 'Paste from clipboard',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isExtracting ? null : onExtract,
            icon: isExtracting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(isExtracting ? 'Extracting...' : 'Extract & Preview'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(begin: 0.04, end: 0);
  }
}

class _ExtractionLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('AI is extracting metadata...',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Generating title, summary & tags',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
            duration: const Duration(milliseconds: 1500),
            color: AppColors.primary.withValues(alpha: 0.1));
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.error)),
          ),
        ],
      ),
    ).animate().fadeIn().shakeX(hz: 2, amount: 4);
  }
}
