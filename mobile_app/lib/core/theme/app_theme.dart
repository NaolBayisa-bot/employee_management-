import 'package:flutter/material.dart';

/// Minimal Material 3 dark theme placeholder.
///
/// The full glassmorphism design system (color tokens, typography, shapes,
/// etc.) is introduced in Task 5. This keeps the app dark-mode-only per the
/// product rules while the scaffold stays compilable and lean.
class AppTheme {
  /// Dark theme (dark mode only per product rules).
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF22D3EE),
      );
}
