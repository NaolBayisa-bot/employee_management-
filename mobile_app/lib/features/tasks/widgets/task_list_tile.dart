// Task list tile widget.
//
// Compact task row showing title, assignee name (or "Unassigned"),
// and a StatusChip for the task status.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/task.dart';
import 'package:employee_management/shared/widgets/status_chip.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.task,
    this.onTap,
    this.trailing,
  });

  final Task task;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final assigneeName = task.assignee?.name ?? 'Unassigned';

    final content = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 12,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    assigneeName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        StatusChip.taskStatus(task.status),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: content,
    );
  }
}