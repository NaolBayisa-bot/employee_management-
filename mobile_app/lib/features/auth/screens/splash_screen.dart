// Splash screen.
//
// Shows the app title and a progress indicator while the auth state is being restored.

import 'package:flutter/material.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/widgets/auth_header.dart';
import 'package:mobile_app/shared/widgets/loading_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthHeader(
                  icon: Icons.task_alt_rounded,
                  title: 'Task Manager',
                  subtitle: 'Loading your session...',
                ),
                const SizedBox(height: AppSpacing.xxl),
                const LoadingView(message: 'Restoring session'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}