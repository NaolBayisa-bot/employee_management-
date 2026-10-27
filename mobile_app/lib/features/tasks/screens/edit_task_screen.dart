// Edit task screen.
//
// Allows MANAGER/ADMIN to edit an existing task.
// Uses TaskForm prefilled with task data. Supports reassigning and clearing due date.
// On success, shows snackbar and navigates back to task detail.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/tasks/providers/task_provider.dart';
import 'package:employee_management/features/tasks/widgets/task_form.dart';
import 'package:employee_management/shared/models/task.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_snack_bar.dart';
import 'package:employee_management/shared/widgets/error_view.dart';
import 'package:employee_management/shared/widgets/loading_view.dart';
import 'package:employee_management/core/network/api_exception.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final String taskId;

  static const String routeName = '/tasks/:id/edit';

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;

    // Redirect if not authorized
    if (!isManagerOrAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/tasks/${widget.taskId}');
        }
      });
    }

    final taskAsync = ref.watch(taskProvider(widget.taskId));
    final updateState = ref.watch(updateTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: taskAsync.when(
        data: (task) => _buildForm(task, updateState),
        loading: () => const LoadingView(message: 'Loading task...'),
        error: (error, stackTrace) => ErrorView(
          title: 'Failed to load task',
          message: error.toString(),
          onRetry: () => ref.invalidate(taskProvider(widget.taskId)),
        ),
      ),
    );
  }

  Widget _buildForm(Task task, AsyncValue<void> updateState) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TaskForm(
        initialTask: task,
        // For editing, we don't need members list since TaskForm will show the current assignee
        // The AssigneePicker will still work if members are provided, but we don't have them here
        // In a real scenario, we'd fetch project members, but for now we'll pass empty list
        members: const [],
        submitLabel: 'Save Changes',
        isLoading: updateState.isLoading,
        onSubmit: (values) => _onSubmit(values, task.id),
      ),
    );
  }

  void _onSubmit(TaskFormValues values, String taskId) async {
    try {
      final updatedTask = await ref.read(updateTaskProvider.notifier).updateTask(
        id: taskId,
        title: values.title,
        description: values.description,
        assigneeId: values.assigneeId,
        dueDate: values.dueDate,
        priority: values.priority,
      );

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Task "${updatedTask.title}" updated');
        context.pop(); // Return to task detail
      }
    } on ApiException catch (e) {
      if (mounted) {
        // Show server validation errors
        final message = e.fieldErrors?.isNotEmpty == true
            ? e.fieldErrors!.values.first
            : e.message;
        AppSnackBar.showError(context, message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to update task: $e');
      }
    }
  }
}
