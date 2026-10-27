// Task detail screen.
//
// Displays full task information with status selector.
// The selector is editable only if the current user is the assignee, or a MANAGER/ADMIN.
// Shows an "Edit" app bar action for MANAGER and ADMIN (placeholder for Task 21).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/tasks/providers/task_provider.dart';
import 'package:mobile_app/features/tasks/widgets/priority_badge.dart';
import 'package:mobile_app/features/tasks/widgets/task_status_selector.dart';
import 'package:mobile_app/features/tasks/widgets/due_date_label.dart';
import 'package:mobile_app/shared/models/task.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_snack_bar.dart';
import 'package:mobile_app/shared/widgets/error_view.dart';
import 'package:mobile_app/shared/widgets/info_row.dart';
import 'package:mobile_app/shared/widgets/loading_view.dart';
import 'package:mobile_app/core/network/api_exception.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  static const String routeName = '/tasks/:id';

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  TaskStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;
    final taskAsync = ref.watch(taskProvider(widget.taskId));
    final updaterState = ref.watch(taskStatusUpdaterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: isManagerOrAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Placeholder for Task 21 - Edit task
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit task coming in Task 21')),
                    );
                  },
                  tooltip: 'Edit task',
                ),
              ]
            : null,
      ),
      body: taskAsync.when(
        data: (task) => _buildTaskContent(task, user, isManagerOrAdmin, updaterState),
        loading: () => const LoadingView(message: 'Loading task...'),
        error: (error, stackTrace) => ErrorView(
          title: 'Failed to load task',
          message: error.toString(),
          onRetry: () => ref.invalidate(taskProvider(widget.taskId)),
        ),
      ),
    );
}

  Widget _buildTaskContent(Task task, User? user, bool isManagerOrAdmin,
      AsyncValue<void> updaterState) {
    _selectedStatus ??= task.status;
    final canEditStatus = _canEditStatus(user, task);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(taskProvider(widget.taskId));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Status selector
                  TaskStatusSelector(
                    current: _selectedStatus ?? task.status,
                    onChanged: canEditStatus ? _onStatusChanged : null,
                    loading: updaterState.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Description
                  _buildSectionTitle('Description'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    task.description?.isNotEmpty == true
                        ? task.description!
                        : 'No description',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: task.description?.isNotEmpty == true
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                      fontStyle:
                          task.description?.isNotEmpty == true ? null : FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Info rows
                  _buildSectionTitle('Details'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRows(task, user),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canEditStatus(User? user, Task task) {
    if (user == null) return false;
    // Assignee can edit
    if (task.assignee?.id == user.id) return true;
    // MANAGER and ADMIN can edit
    if (user.role == Role.manager || user.role == Role.admin) return true;
    return false;
  }

  void _onStatusChanged(TaskStatus newStatus) async {
    if (_selectedStatus == newStatus) return;

    final previousStatus = _selectedStatus;
    setState(() {
      _selectedStatus = newStatus;
    });

    try {
      await ref.read(taskStatusUpdaterProvider.notifier).updateStatus(
            widget.taskId,
            newStatus,
          );
      if (mounted) {
        AppSnackBar.showSuccess(context, 'Status updated to ${newStatus.label}');
      }
    } catch (e) {
      // Revert on failure
      setState(() {
        _selectedStatus = previousStatus;
      });
      if (mounted) {
        final message = e is ApiException ? e.message : 'Failed to update status';
        AppSnackBar.showError(context, message);
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoRows(Task task, User? currentUser) {
    return Column(
      children: [
        // Project
        InfoRow(
          icon: Icons.folder_outlined,
          label: 'Project',
          value: task.project?.name ?? 'Unknown',
        ),
        // Assignee
        InfoRow(
          icon: Icons.person_outline,
          label: 'Assignee',
          value: task.assignee?.name ?? 'Unassigned',
        ),
        // Created by
        InfoRow(
          icon: Icons.account_circle_outlined,
          label: 'Created by',
          value: task.createdBy?.name ?? 'Unknown',
        ),
        // Due date
        if (task.dueDate != null)
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Due date',
            value: _formatDueDate(task.dueDate!, task.isOverdue),
            valueWidget: DueDateLabel(date: task.dueDate, overdue: task.isOverdue),
          ),
        // Priority
        InfoRow(
          icon: Icons.flag_outlined,
          label: 'Priority',
          value: '',
          valueWidget: PriorityBadge(priority: task.priority),
        ),
      ],
    );
  }

  String _formatDueDate(DateTime date, bool overdue) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (date.isAfter(todayDate.subtract(const Duration(days: 1))) &&
        !date.isAfter(todayDate)) {
      return overdue ? 'Today (Overdue)' : 'Today';
    }
    if (date.isAfter(todayDate) &&
        !date.isAfter(todayDate.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}${overdue ? ' (Overdue)' : ''}';
  }
}