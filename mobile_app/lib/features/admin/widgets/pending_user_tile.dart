// PendingUserTile widget.
//
// Displays a pending user with Avatar, name, email, joined date,
// a role selector (Manager/Employee), and an Approve button with loading state.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/avatar.dart';
import 'package:mobile_app/shared/widgets/glass_card.dart';

class PendingUserTile extends StatefulWidget {
  const PendingUserTile({
    super.key,
    required this.user,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onApprove,
    this.loading = false,
  });

  final User user;
  final Role selectedRole;
  final ValueChanged<Role> onRoleChanged;
  final VoidCallback onApprove;
  final bool loading;

  @override
  State<PendingUserTile> createState() => _PendingUserTileState();
}

class _PendingUserTileState extends State<PendingUserTile> {
  late Role _currentRole;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.selectedRole;
  }

  @override
  void didUpdateWidget(covariant PendingUserTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRole != widget.selectedRole) {
      _currentRole = widget.selectedRole;
    }
  }

  void _handleRoleChanged(Role newRole) {
    setState(() {
      _currentRole = newRole;
    });
    widget.onRoleChanged(newRole);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.loading;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // User info row
          Row(
            children: [
              // Avatar
              Avatar(
                name: widget.user.name,
                size: AvatarSize.medium,
              ),
              const SizedBox(width: AppSpacing.md),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.user.email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Joined ${_formatDate(widget.user.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Actions row: role selector and approve button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Role selector (Manager/Employee only)
              _RoleSelector(
                value: _currentRole,
                onChanged: _handleRoleChanged,
                disabled: isLoading,
              ),
              const SizedBox(width: AppSpacing.md),
              // Approve button with constrained width
              SizedBox(
                width: 140,
                child: AppButton(
                  label: 'Approve',
                  variant: AppButtonVariant.primary,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : widget.onApprove,
                  leadingIcon: const Icon(Icons.check_rounded, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// Private role selector limited to Manager and Employee
class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  final Role value;
  final ValueChanged<Role> onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Role>(
          value: value,
          isDense: true,
          disabledHint: Text(
            value.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: disabled ? AppColors.textDisabled : AppColors.textPrimary,
            ),
          ),
          icon: disabled
              ? null
              : Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
          dropdownColor: AppColors.surfaceContainer,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: const [
            DropdownMenuItem(
              value: Role.manager,
              child: Text('Manager'),
            ),
            DropdownMenuItem(
              value: Role.employee,
              child: Text('Employee'),
            ),
          ],
          onChanged: disabled
              ? null
              : (newRole) {
                  if (newRole != null) onChanged(newRole);
                },
        ),
      ),
    );
  }
}
