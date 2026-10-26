// Projects screen placeholder.
//
// Placeholder for the projects list screen showing all projects.
// Will be replaced with real projects implementation in a future task.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  static const String routeName = '/projects';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Projects',
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