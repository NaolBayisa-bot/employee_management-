// Profile info section widget.
//
// Displays user metadata like member since, user ID, etc.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/glass_card.dart';
import 'package:mobile_app/shared/widgets/info_row.dart';

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          // Section title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Account Information',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Member since
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: _formatDate(user.createdAt),
          ),
          const Divider(color: AppColors.divider, height: AppSpacing.xl),

          // User ID
          InfoRow(
            icon: Icons.badge_outlined,
            label: 'User ID',
            value: user.id,
            isMonospace: true,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}