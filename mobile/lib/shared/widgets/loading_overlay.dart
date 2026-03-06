import 'package:flutter/material.dart';

/// Wraps [child] with a translucent loading overlay when [isLoading] is true.
/// When [isLoading] is false it renders [child] directly without any overhead.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Stack(
      children: [
        child,
        const Positioned.fill(
          child: ColoredBox(
            color: Colors.black26,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
