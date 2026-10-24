import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Frosted glassmorphism card implementing ClipRRect, optional BackdropFilter,
/// translucent surface fill, 1px border, and subtle top highlight.
///
/// When [onTap] is provided, tapping brightens the fill (pressed state) with a
/// ripple-free effect.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.blur = true,
    this.onTap,
    this.borderRadius = AppRadius.cardRadius,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool blur;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ??
        (_isPressed ? AppColors.glassFillPressed : AppColors.glassFill);
    final effectiveBorderColor = widget.borderColor ?? AppColors.glassBorder;

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: widget.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glassHighlight,
            offset: Offset(0, 1),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.blur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppBlur.card,
          sigmaY: AppBlur.card,
        ),
        child: content,
      );
    }

    content = ClipRRect(
      borderRadius: widget.borderRadius,
      child: content,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: content,
      );
    }

    if (widget.margin != null) {
      content = Padding(padding: widget.margin!, child: content);
    }

    return content;
  }
}
