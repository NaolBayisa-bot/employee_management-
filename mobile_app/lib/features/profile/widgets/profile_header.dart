// Profile header widget.
//
// Displays user avatar, name, email, and role/status chips.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/avatar.dart';
import 'package:employee_management/shared/widgets/status_chip.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Avatar(
          name: user.name,
          size: AvatarSize.large,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Name
        Text(
          user.name,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Email
        Text(
          user.email,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Role and Status chips
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            StatusChip.role(user.role),
            StatusChip.userStatus(user.status),
          ],
        ),
      ],
    );
  }
}