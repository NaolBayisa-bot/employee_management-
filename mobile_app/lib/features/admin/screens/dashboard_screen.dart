// Dashboard screen placeholder.
//
// Placeholder for the admin dashboard showing key metrics and overview.
// Will be replaced with real dashboard implementation in a future task.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Dashboard',
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