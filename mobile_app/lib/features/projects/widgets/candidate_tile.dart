// Candidate tile widget.
//
// Displays a candidate user with avatar, name, role chip, and a trailing
// "Add" button (or a "Member" label if already in the project).
//
// When [isLoading] is true, the Add button shows a spinner and is disabled.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_button.dart';
import 'package:employee_management/shared/widgets/avatar.dart';
import 'package:employee_management/shared/widgets/status_chip.dart';

class CandidateTile extends StatelessWidget {
  const CandidateTile({
    super.key,
    required this.candidate,
    required this.isMember,
    required this.onAdd,
    this.isLoading = false,
  });

  final Candidate candidate;
  final bool isMember;
  final VoidCallback onAdd;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final trailing = isMember
        ? Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: AppColors.primary, width: 1.0),
            ),
            child: Text(
              'Member',
              style: AppText.monoStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : AppButton(
            label: 'Add',
            variant: AppButtonVariant.text,
            fullWidth: false,
            height: 32,
            isLoading: isLoading,
            leadingIcon: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.person_add, size: 14),
            onPressed: isLoading ? null : onAdd,
          );

    final content = Row(
      children: [
        Avatar(
          name: candidate.name,
          size: AvatarSize.medium,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                candidate.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              StatusChip.role(candidate.role),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        trailing,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: content,
    );
  }
}