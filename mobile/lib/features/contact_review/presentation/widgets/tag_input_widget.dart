import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TagInputWidget extends StatefulWidget {
  const TagInputWidget({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.maxTags = 5,
    this.suggestions = const [],
  });

  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final int maxTags;
  final List<String> suggestions;

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isEmpty) return;
    if (widget.tags.length >= widget.maxTags) return;
    if (widget.tags.contains(trimmed)) return;

    final newTags = [...widget.tags, trimmed];
    widget.onTagsChanged(newTags);
    _controller.clear();
  }

  void _removeTag(String tag) {
    final newTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(newTags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAddMore = widget.tags.length < widget.maxTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag chips
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
                deleteIconColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.labelMedium,
                visualDensity: VisualDensity.compact,
                backgroundColor:
                    theme.colorScheme.secondaryContainer.withOpacity(0.7),
              );
            }).toList(),
          ),
          const Gap(8),
        ],

        // Input field
        if (canAddMore)
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.tags.isEmpty
                  ? 'Add tags (e.g. prospect, met-at-conf)...'
                  : 'Add another tag...',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => _addTag(_controller.text),
                visualDensity: VisualDensity.compact,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: _addTag,
          )
        else
          Text(
            'Maximum ${widget.maxTags} tags reached',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

        // Suggestions
        if (canAddMore && widget.suggestions.isNotEmpty) ...[
          const Gap(8),
          Text(
            'Suggestions:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.suggestions
                .where((s) => !widget.tags.contains(s))
                .take(6)
                .map(
                  (s) => ActionChip(
                    label: Text(s),
                    onPressed: () => _addTag(s),
                    visualDensity: VisualDensity.compact,
                    labelStyle: theme.textTheme.labelSmall,
                  ),
                )
                .toList(),
          ),
        ],

        // Count indicator
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${widget.tags.length}/${widget.maxTags}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
