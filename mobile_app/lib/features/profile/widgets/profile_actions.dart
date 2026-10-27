// Profile actions widget.
//
// Displays action buttons like logout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/shared/widgets/app_button.dart';

class ProfileActions extends ConsumerWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Logout',
      variant: AppButtonVariant.secondary,
      leadingIcon: const Icon(Icons.logout),
      onPressed: () => ref.read(authProvider.notifier).logout(),
    );
  }
}