// Waiting for approval screen.
//
// Shown when a registered user (PENDING status) tries to access the app.
// Allows the user to check again for approval or log out.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/auth/widgets/status_message_view.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/app_snack_bar.dart';

class WaitingApprovalScreen extends ConsumerStatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  ConsumerState<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends ConsumerState<WaitingApprovalScreen> {
  bool _checking = false;

  Future<void> _checkAgain() async {
    setState(() => _checking = true);
    try {
      final user = await ref.read(authProvider.notifier).refreshMe();
      if (!mounted) return;
      if (user == null) {
        // Session expired or logged out
        AppSnackBar.showError(context, 'Session expired. Please log in again.');
        return;
      }
      if (user.status.name == 'pending') {
        AppSnackBar.showError(context, 'Account still pending approval.');
      }
      // If status changed, the router redirect will handle navigation
    } on Exception catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Failed to check status. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                icon: Icons.hourglass_top_rounded,
                title: 'Awaiting Approval',
                message: 'Your account is pending admin approval. '
                    'You will be able to access the app once an admin activates your account.',
                iconColor: AppColors.warning,
                iconBackgroundColor: AppColors.warningFill,
                actions: [
                  AppButton(
                    label: 'Check Again',
                    isLoading: _checking,
                    onPressed: _checking ? null : _checkAgain,
                    variant: AppButtonVariant.primary,
                  ),
                  AppButton(
                    label: 'Logout',
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    variant: AppButtonVariant.secondary,
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