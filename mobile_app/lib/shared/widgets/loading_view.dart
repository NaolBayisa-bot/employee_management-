import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Loading view providing both a spinner-based indicator and pure-Flutter
/// shimmer skeleton placeholders without requiring third-party dependencies.
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer-style animated skeleton placeholder built using plain Flutter containers.
class SkeletonPlaceholder extends StatefulWidget {
  const SkeletonPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius = AppRadius.inputRadius,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonPlaceholder> createState() => _SkeletonPlaceholderState();
}

class _SkeletonPlaceholderState extends State<SkeletonPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.glassFillPressed.withValues(
              alpha: _animation.value * 0.25,
            ),
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: AppColors.glassBorder.withValues(
                alpha: _animation.value * 0.2,
              ),
              width: 1.0,
            ),
          ),
        );
      },
    );
  }
}
