// Task card widget.
//
// A rich task card showing title, description, project name, priority,
// due date with overdue indicator, and status chip.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/task.dart';
import 'package:employee_management/features/tasks/widgets/due_date_label.dart';
import 'package:employee_management/features/tasks/widgets/priority_badge.dart';
import 'package:employee_management/shared/widgets/status_chip.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with priority badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            PriorityBadge(priority: task.priority),
          ],
        ),
        // Description
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            task.description!,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        // Meta row: project, due date, status
        Row(
          children: [
            // Project name
            if (task.project != null) ...[
              Icon(
                Icons.folder_outlined,
                size: 14,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  task.project!.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            // Due date
            if (task.dueDate != null) ...[
              DueDateLabel(
                date: task.dueDate,
                overdue: task.isOverdue,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            // Status chip
            StatusChip.taskStatus(task.status),
          ],
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.glassBorder, width: 1.0),
            // Subtle red accent for overdue tasks
            boxShadow: task.isOverdue
                ? [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
        boxShadow: task.isOverdue
            ? [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: content,
    );
  }
}

