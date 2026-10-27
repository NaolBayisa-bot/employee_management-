// StatCard widget.
//
// A compact stat tile with label, value, icon, and optional accent color.
// Includes a skeleton loading variant via StatCard.loading().

import 'package:flutter/material.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/widgets/glass_card.dart';
import 'package:employee_management/shared/widgets/loading_view.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  }) : _isLoading = false;

  /// Creates a skeleton loading variant.
  const StatCard.loading({super.key})
      : label = '',
        value = 0,
        icon = Icons.analytics_outlined,
        accent = null,
        _isLoading = true;

  final String label;
  final int value;
  final IconData icon;
  final Color? accent;
  final bool _isLoading;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            SkeletonPlaceholder(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            const SizedBox(height: AppSpacing.md),
            // Value placeholder
            SkeletonPlaceholder(
              width: 80,
              height: 28,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Label placeholder
            SkeletonPlaceholder(
              width: 100,
              height: 14,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
          ],
        ),
      );
    }

    final effectiveAccent = accent ?? AppColors.primary;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with accent background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: effectiveAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Icon(
              icon,
              color: effectiveAccent,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Value
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
