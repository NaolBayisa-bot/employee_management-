// Priority selector widget.
//
// Segmented control Low, Medium, High using the priority colors.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/task.dart';

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Priority',
  });

  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: AppColors.glassBorder, width: 1.0),
          ),
          child: Row(
            children: TaskPriority.values.map((priority) {
              final isSelected = value == priority;
              final token = AppColors.forPriority(priority);

              return Expanded(
                child: TextButton(
                  onPressed: () => onChanged(priority),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    backgroundColor: isSelected ? token.fill : Colors.transparent,
                    foregroundColor: isSelected ? token.text : token.text,
                    side: BorderSide(
                      color: isSelected ? token.border : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        priority.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.onPrimary : token.text,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.check,
                          size: 12,
                          color: isSelected ? AppColors.onPrimary : token.text,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
