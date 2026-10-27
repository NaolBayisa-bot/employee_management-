// StatsGrid widget.
//
// A responsive two-column grid of five StatCards displaying dashboard statistics.

import 'package:flutter/material.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/admin/widgets/stat_card.dart';
import 'package:employee_management/shared/models/dashboard_stats.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.stats,
  });

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 2 columns on wider screens, 1 column on narrow screens
        final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: constraints.maxWidth >= 600 ? 1.8 : 2.2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: [
            StatCard(
              label: 'Total Users',
              value: stats.totalUsers,
              icon: Icons.people_outline,
              accent: AppColors.primary,
            ),
            StatCard(
              label: 'Pending Approvals',
              value: stats.pendingUsers,
              icon: Icons.hourglass_empty_outlined,
              accent: AppColors.warning,
            ),
            StatCard(
              label: 'Active Projects',
              value: stats.activeProjects,
              icon: Icons.folder_outlined,
              accent: AppColors.success,
            ),
            StatCard(
              label: 'Open Tasks',
              value: stats.openTasks,
              icon: Icons.assignment_outlined,
              accent: AppColors.secondary,
            ),
            StatCard(
              label: 'Completed Tasks',
              value: stats.doneTasks,
              icon: Icons.task_alt_outlined,
              accent: AppColors.tertiary,
            ),
          ],
        );
      },
    );
  }
}
