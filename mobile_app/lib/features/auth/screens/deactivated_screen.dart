// Deactivated account screen.
//
// Shown when a user with DEACTIVATED status tries to access the app.
// Only option is to log out.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/auth/widgets/status_message_view.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';

class DeactivatedScreen extends ConsumerWidget {
  const DeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: StatusMessageView(
                icon: Icons.block_rounded,
                title: 'Account Deactivated',
                message: 'Your account has been deactivated. '
                    'Please contact support if you believe this is a mistake.',
                iconColor: AppColors.error,
                iconBackgroundColor: AppColors.errorFill,
                actions: [
                  AppButton(
                    label: 'Logout',
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}