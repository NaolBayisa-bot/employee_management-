import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/shared/models/task.dart';

/// A segmented control with To do, In progress, Done tabs.
///
/// Disabled (read only) when [onChanged] is null.
/// Shows a progress indicator while [loading] is true.
class TaskStatusSelector extends StatefulWidget {
  const TaskStatusSelector({
    super.key,
    required this.current,
    this.onChanged,
    this.loading = false,
  });

  final TaskStatus current;
  final ValueChanged<TaskStatus>? onChanged;
  final bool loading;

  @override
  State<TaskStatusSelector> createState() => _TaskStatusSelectorState();
}

class _TaskStatusSelectorState extends State<TaskStatusSelector> {
  late TaskStatus _current;

  @override
  void initState() {
    super.initState();
    _current = widget.current;
  }

  void _handleChange(TaskStatus newStatus) {
    if (widget.onChanged != null) {
      widget.onChanged!.call(newStatus);
    }
    setState(() {
      _current = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.onChanged == null;
    final buttonStyle = isReadOnly
        ? ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.glassFill),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
            ),
          )
        : ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return null;
              },
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
      ),
      child: Row(
        children: TaskStatus.values.map((status) {
          final isSelected = _current == status;
          final token = AppColors.forTaskStatus(status);

          return Expanded(
            child: TextButton(
              onPressed: isReadOnly
                  ? null
                  : widget.loading
                      ? null
                      : () => _handleChange(status),
              style: buttonStyle,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: widget.loading
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            status.label,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : token.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...const [
                            SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.check,
                              size: 12,
                              color: AppColors.onPrimary,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}