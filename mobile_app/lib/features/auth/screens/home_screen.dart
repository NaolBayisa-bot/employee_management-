// Home screen placeholder.
//
// Temporary screen shown after successful login for ACTIVE users.
// Displays user name, role, and a logout button.
// Will be replaced by the real app shell in a future task.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/auth/widgets/auth_header.dart';
import 'package:employee_management/shared/widgets/app_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    if (user == null) {
      // Should not happen due to router guards, but handle gracefully
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                icon: Icons.check_circle_outline,
                title: 'Welcome',
                subtitle: 'You are logged in and active.',
              ),
              const SizedBox(height: AppSpacing.xl),
              _infoRow('Name', user.name),
              const SizedBox(height: AppSpacing.md),
              _infoRow('Email', user.email),
              const SizedBox(height: AppSpacing.md),
              _infoRow('Role', user.role?.toServerValue() ?? '—'),
              const SizedBox(height: AppSpacing.md),
              _infoRow('Status', user.status.toServerValue()),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Logout',
                variant: AppButtonVariant.secondary,
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}