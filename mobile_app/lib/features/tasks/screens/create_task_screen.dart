// Create task screen.
//
// Allows MANAGER/ADMIN to create a new task for a project.
// Loads project members for the AssigneePicker. Uses TaskForm.
// On success, shows snackbar and navigates back to project detail.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/projects/providers/project_provider.dart';
import 'package:employee_management/features/tasks/providers/task_provider.dart';
import 'package:employee_management/features/tasks/widgets/task_form.dart';
import 'package:employee_management/shared/models/project.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_snack_bar.dart';
import 'package:employee_management/shared/widgets/error_view.dart';
import 'package:employee_management/shared/widgets/loading_view.dart';
import 'package:employee_management/core/network/api_exception.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key, required this.projectId});

  final String projectId;

  static const String routeName = '/projects/:projectId/tasks/new';

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;
    
    // Redirect if not authorized
    if (!isManagerOrAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/projects/${widget.projectId}');
        }
      });
    }

    final projectAsync = ref.watch(projectProvider(widget.projectId));
    final createState = ref.watch(createTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: projectAsync.when(
        data: (project) => _buildForm(project, createState),
        loading: () => const LoadingView(message: 'Loading project...'),
        error: (error, stackTrace) => ErrorView(
          title: 'Failed to load project',
          message: error.toString(),
          onRetry: () => ref.invalidate(projectProvider(widget.projectId)),
        ),
      ),
    );
  }

  Widget _buildForm(Project project, AsyncValue<void> createState) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TaskForm(
        members: project.members,
        submitLabel: 'Create Task',
        isLoading: createState.isLoading,
        onSubmit: (values) => _onSubmit(values, project.id),
      ),
    );
  }

  void _onSubmit(TaskFormValues values, String projectId) async {
    try {
      final createdTask = await ref.read(createTaskProvider.notifier).createTask(
        title: values.title,
        description: values.description,
        projectId: projectId,
        assigneeId: values.assigneeId,
        dueDate: values.dueDate,
        priority: values.priority,
      );

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Task "${createdTask.title}" created');
        context.pop(); // Return to project detail
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
        AppSnackBar.showError(context, 'Failed to create task: $e');
      }
    }
  }
}
