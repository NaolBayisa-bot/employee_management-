import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Full-screen ambient dark glassmorphism background that paints a diagonal
/// gradient and three static soft glowing orbs (Cyan, Violet, Blue) positioned
/// in distinct corners using efficient radial gradients.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(
          child: CustomPaint(
            painter: _AppBackgroundPainter(),
            size: Size.infinite,
          ),
        ),
        child,
      ],
    );
  }
}

class _AppBackgroundPainter extends CustomPainter {
  const _AppBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Diagonal gradient canvas: obsidian navy (#0A0E1A) to dark surface (#0F131F)
    final bgPaint = Paint()
      ..shader = AppColors.backgroundGradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Cyan orb (top-left)
    final cyanCenter = Offset(size.width * 0.10, size.height * 0.12);
    final cyanRadius = size.width * 0.55;
    final cyanPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.orbCyan.withValues(alpha: 0.20),
          AppColors.orbCyan.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: cyanCenter, radius: cyanRadius));
    canvas.drawCircle(cyanCenter, cyanRadius, cyanPaint);

    // 3. Violet orb (upper/mid-right)
    final violetCenter = Offset(size.width * 0.90, size.height * 0.38);
    final violetRadius = size.width * 0.65;
    final violetPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.orbViolet.withValues(alpha: 0.22),
          AppColors.orbViolet.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: violetCenter, radius: violetRadius));
    canvas.drawCircle(violetCenter, violetRadius, violetPaint);

    // 4. Blue orb (bottom-left)
    final blueCenter = Offset(size.width * 0.20, size.height * 0.82);
    final blueRadius = size.width * 0.60;
    final bluePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.orbBlue.withValues(alpha: 0.18),
          AppColors.orbBlue.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: blueCenter, radius: blueRadius));
    canvas.drawCircle(blueCenter, blueRadius, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
