// Project card widget.
//
// Displays project information: name, truncated description, owner name,
// member count, task count, and an "Archived" chip when applicable.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/project.dart';
import 'package:employee_management/shared/widgets/glass_card.dart';
import 'package:employee_management/shared/widgets/status_chip.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: name + archived chip
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (project.status == ProjectStatus.archived) ...[
                const SizedBox(width: AppSpacing.sm),
                StatusChip.projectStatus(ProjectStatus.archived),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Description (2 lines max)
          if (project.description != null && project.description!.isNotEmpty)
            Text(
              project.description!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              'No description',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: AppSpacing.md),

          // Footer: owner, member count, task count
          Row(
            children: [
              if (project.owner != null) ...[
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  project.owner!.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              _buildStat(
                Icons.group_outlined,
                '${project.memberCount} members',
              ),
              const SizedBox(width: AppSpacing.md),
              _buildStat(
                Icons.assignment_outlined,
                '${project.taskCount} tasks',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textDisabled),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}