// Auth screen header: an app icon/logo, a title and a subtitle.
//
// Used by the login screen (Task 7). Also showcased in the Design Preview
// gallery (Task 7 step 1: "add it to the gallery").

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.icon = Icons.lock_rounded,
    this.title = 'Welcome',
    this.subtitle = 'Sign in to continue',
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(
            icon,
            size: 56,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
