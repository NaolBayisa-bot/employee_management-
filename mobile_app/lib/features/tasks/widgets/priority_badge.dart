import 'package:flutter/material.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/shared/models/task.dart';

/// A small colored badge with a priority label.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.priority,
  });

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final token = AppColors.forPriority(priority);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: token.fill,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: token.border, width: 1.0),
      ),
      child: Text(
        priority.label,
        style: AppText.monoStyle(
          color: token.text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}