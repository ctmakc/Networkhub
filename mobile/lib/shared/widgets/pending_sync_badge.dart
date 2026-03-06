import 'package:flutter/material.dart';

/// A small badge shown in the app bar when there are contacts waiting to be
/// synced to the server (offline mode or sync error).
class PendingSyncBadge extends StatelessWidget {
  const PendingSyncBadge({super.key, this.count});

  /// Number of pending items.  When null the badge is hidden.
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (count == null || count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
