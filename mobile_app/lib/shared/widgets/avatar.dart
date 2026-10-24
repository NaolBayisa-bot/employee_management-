import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';

enum AvatarSize {
  small(32.0, 12.0),
  medium(44.0, 16.0),
  large(64.0, 24.0);

  const AvatarSize(this.dimension, this.fontSize);
  final double dimension;
  final double fontSize;
}

/// Circular avatar showing user initials with a glowing gradient ring.
/// Handles empty, one-word, and very long names gracefully.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.name,
    this.size = AvatarSize.medium,
    this.gradient,
  });

  final String? name;
  final AvatarSize size;
  final Gradient? gradient;

  /// Extracts initials:
  /// - null/empty/whitespace: '?'
  /// - single word: 'A'
  /// - multiple words: first letter of first two words, e.g. 'JD'
  static String extractInitials(String? name) {
    if (name == null) return '?';
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = extractInitials(name);
    final effectiveGradient = gradient ?? AppColors.buttonGradient;

    return Container(
      width: size.dimension,
      height: size.dimension,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: effectiveGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.orbCyan.withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerHigh,
        ),
        child: Center(
          child: Text(
            initials,
            style: GoogleFonts.spaceGrotesk(
              fontSize: size.fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
