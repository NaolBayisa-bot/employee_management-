import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Key-value information row displaying an icon, label, and formatted value.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidget,
    this.isMonospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          valueWidget ??
              Text(
                value,
                style: isMonospace
                    ? AppText.monoStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      )
                    : const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
              ),
        ],
      ),
    );
  }
}
