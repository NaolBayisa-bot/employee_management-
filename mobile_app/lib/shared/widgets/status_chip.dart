import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../shared/models/project.dart';
import '../../shared/models/task.dart';
import '../../shared/models/user.dart';

/// Tinted glass pill badge with colored text, border, and monospace typography.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.token,
    this.dot = false,
  });

  final String label;
  final StatusColorToken token;
  final bool dot;

  factory StatusChip.taskStatus(TaskStatus status,
      {Key? key, bool dot = false}) {
    return StatusChip(
      key: key,
      label: status.label,
      token: AppColors.forTaskStatus(status),
      dot: dot,
    );
  }

  factory StatusChip.priority(TaskPriority priority,
      {Key? key, bool dot = false}) {
    return StatusChip(
      key: key,
      label: priority.label,
      token: AppColors.forPriority(priority),
      dot: dot,
    );
  }

  factory StatusChip.role(Role? role, {Key? key, bool dot = false}) {
    return StatusChip(
      key: key,
      label: role?.toServerValue() ?? '—',
      token: AppColors.forRole(role),
      dot: dot,
    );
  }

  factory StatusChip.userStatus(UserStatus status,
      {Key? key, bool dot = false}) {
    return StatusChip(
      key: key,
      label: status.toServerValue(),
      token: AppColors.forUserStatus(status),
      dot: dot,
    );
  }

  factory StatusChip.projectStatus(ProjectStatus status,
      {Key? key, bool dot = false}) {
    return StatusChip(
      key: key,
      label: status.toServerValue(),
      token: AppColors.forProjectStatus(status),
      dot: dot,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: token.fill,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: token.border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: token.text,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: token.text.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppText.monoStyle(
              color: token.text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
