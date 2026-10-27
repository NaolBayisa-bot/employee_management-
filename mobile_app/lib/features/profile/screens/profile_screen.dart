// Profile screen.
//
// Displays the current user's profile information including avatar, name,
// email, role, status, and account metadata. Provides a logout action.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/profile/widgets/profile_actions.dart';
import 'package:employee_management/features/profile/widgets/profile_header.dart';
import 'package:employee_management/features/profile/widgets/profile_info_section.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Should not happen due to router guards, but handle gracefully
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }
        return _ProfileContent(user: user);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Failed to load profile',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Retry',
                  variant: AppButtonVariant.primary,
                  onPressed: () => ref.read(authProvider.notifier).refreshMe(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Header with avatar, name, email, role/status
              ProfileHeader(user: user),
              const SizedBox(height: AppSpacing.xl),

              // Account information section
              ProfileInfoSection(user: user),
              const SizedBox(height: AppSpacing.xl),

              // Actions (logout)
              ProfileActions(),
            ],
          ),
        ),
      ),
    );
  }
}