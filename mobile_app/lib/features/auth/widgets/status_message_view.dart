// Status message view widget.
//
// Reusable component for screens that need to show an illustration icon,
// title, message, and action buttons (e.g., waiting for approval, deactivated).

import 'package:flutter/material.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';

class StatusMessageView extends StatelessWidget {
  const StatusMessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const [],
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize = 56,
    this.containerSize = 88,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double iconSize;
  final double containerSize;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.secondary;
    final effectiveBgColor = iconBackgroundColor ?? AppColors.glassFill;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveBgColor,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: effectiveIconColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: actions
                .expand((widget) => [
                      widget,
                      const SizedBox(height: AppSpacing.md),
                    ])
                .take(actions.length * 2 - 1)
                .toList(),
          ),
        ],
      ],
    );
  }
}