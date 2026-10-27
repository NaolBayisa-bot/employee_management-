// Assignee picker widget.
//
// Dropdown or bottom sheet listing project members with Avatar and name,
// plus an "Unassigned" option.

import 'package:flutter/material.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/avatar.dart';
import 'package:employee_management/shared/widgets/glass_dialogs.dart';

class AssigneePicker extends StatelessWidget {
  const AssigneePicker({
    super.key,
    required this.members,
    required this.selectedId,
    required this.onChanged,
    this.label = 'Assignee',
  });

  final List<ProjectMember> members;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.person_outline, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: AppColors.primary, width: 2.0),
          ),
          filled: true,
          fillColor: AppColors.glassFill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedId != null && selectedId!.isNotEmpty)
              Avatar(
                name: _getSelectedName(),
                size: AvatarSize.small,
              )
            else
              const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _getSelectedName(),
                style: TextStyle(
                  color: (selectedId != null && selectedId!.isNotEmpty)
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _getSelectedName() {
    if (selectedId == null || selectedId!.isEmpty) return 'Select assignee';
    final member = members.firstWhere(
      (m) => m.id == selectedId,
      orElse: () => ProjectMember(id: '', name: 'Unknown'),
    );
    return member.name;
  }

  void _showPicker(BuildContext context) {
    showGlassBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AssigneePickerSheet(
        members: members,
        selectedId: selectedId,
        onSelected: onChanged,
      ),
    );
  }
}

class _AssigneePickerSheet extends StatelessWidget {
  const _AssigneePickerSheet({
    required this.members,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ProjectMember> members;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Select Assignee',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: members.length + 1,
            separatorBuilder: (_, _) =>
                const Divider(color: AppColors.divider, height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildMemberTile(
                  context,
                  id: '',
                  name: 'Unassigned',
                  role: null,
                  avatarName: null,
                  isSelected: selectedId == null || selectedId!.isEmpty,
                );
              }
              final member = members[index - 1];
              return _buildMemberTile(
                context,
                id: member.id,
                name: member.name,
                role: member.role,
                avatarName: member.name,
                isSelected: selectedId == member.id,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    {
    required String id,
    required String name,
    required Role? role,
    required String? avatarName,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onSelected(id.isEmpty ? null : id);
      },
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        child: Row(
          children: [
            Avatar(
              name: avatarName,
              size: AvatarSize.medium,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (role != null)
                    Text(
                      _roleLabel(role),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  String _roleLabel(Role role) {
    switch (role) {
      case Role.admin:
        return 'Admin';
      case Role.manager:
        return 'Manager';
      case Role.employee:
        return 'Employee';
    }
  }
}
