// Project status filter widget.
//
// Segmented control for filtering projects by status: Active, Archived, All.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/shared/models/project.dart';

class ProjectStatusFilter extends StatelessWidget {
  const ProjectStatusFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ProjectStatus? selected;
  final ValueChanged<ProjectStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            label: 'All',
            value: null,
            isSelected: selected == null,
          ),
          _buildDivider(),
          _buildSegment(
            label: 'Active',
            value: ProjectStatus.active,
            isSelected: selected == ProjectStatus.active,
          ),
          _buildDivider(),
          _buildSegment(
            label: 'Archived',
            value: ProjectStatus.archived,
            isSelected: selected == ProjectStatus.archived,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.glassBorder,
    );
  }

  Widget _buildSegment({
    required String label,
    required ProjectStatus? value,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}