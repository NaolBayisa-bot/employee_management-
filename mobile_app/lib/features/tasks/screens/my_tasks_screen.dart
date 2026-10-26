// My Tasks screen placeholder.
//
// Placeholder for the my tasks screen showing assigned tasks.
// Will be replaced with real tasks implementation in a future task.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  static const String routeName = '/my-tasks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'My Tasks',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}