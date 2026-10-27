// Create project screen.
// 
// Allows MANAGER/ADMIN to create a new project using ProjectForm.
// On success, navigates to the new project's detail screen and shows a success snackbar.
// Shows server field errors on the form.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:employee_management/core/network/api_exception.dart';
import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/projects/data/project_repository.dart';
import 'package:employee_management/features/projects/providers/project_provider.dart';
import 'package:employee_management/features/projects/widgets/project_form.dart';
import 'package:employee_management/shared/models/project.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_button.dart';
import 'package:employee_management/shared/widgets/app_snack_bar.dart';
import 'package:employee_management/shared/widgets/glass_card.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  static const String routeName = '/projects/new';

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  bool _isLoading = false;
  Map<String, String>? _fieldErrors;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(String name, String description) async {
    setState(() {
      _isLoading = true;
      _fieldErrors = null;
    });

    try {
      final repository = ref.read(projectRepositoryProvider);
      final project = await repository.createProject(
        name: name,
        description: description,
      );

      if (!mounted) return;

      // Invalidate providers to refresh project lists
      ref.invalidate(projectsProvider(null));
      ref.invalidate(projectsProvider(ProjectStatus.active));
      ref.invalidate(projectsProvider(ProjectStatus.archived));
      ref.invalidate(filteredProjectsProvider);
      ref.invalidate(projectProvider(project.id));

      // Show success snackbar
      AppSnackBar.showSuccess(context, 'Project created successfully');

      // Navigate to project detail
      if (mounted) {
        context.go('/projects/${project.id}');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _fieldErrors = e.fieldErrors;
      });
      if (e.fieldErrors == null || e.fieldErrors!.isEmpty) {
        AppSnackBar.showError(context, e.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppSnackBar.showError(context, 'Failed to create project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;

    // Redirect non-manager/admin users
    if (!isManagerOrAdmin) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Access Denied',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Only managers and admins can create projects.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Back to Projects',
                  variant: AppButtonVariant.primary,
                  onPressed: () => context.go('/projects'),
                  fullWidth: false,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/projects'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ProjectForm(
              submitLabel: 'Create Project',
              isLoading: _isLoading,
              nameFocusNode: _nameFocusNode,
              descriptionFocusNode: _descriptionFocusNode,
              onSubmit: _onSubmit,
              fieldErrors: _fieldErrors,
            ),
          ),
        ),
      ),
    );
  }
}