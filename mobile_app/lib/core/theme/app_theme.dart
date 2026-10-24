import 'package:flutter/material.dart';

class AppTheme {
  // Minimal Material 3 theme — full design system arrives in Task 5.
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  );
}
