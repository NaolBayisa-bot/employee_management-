import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Monospace typography text widget specifically styled for numbers,
/// metrics, timestamps, codes, and IDs using JetBrains Mono.
class MonoText extends StatelessWidget {
  const MonoText(
    this.text, {
    super.key,
    this.fontSize = 13.0,
    this.fontWeight = FontWeight.w500,
    this.color = AppColors.textPrimary,
    this.letterSpacing = -0.01,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: AppText.monoStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
