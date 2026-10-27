// Edit project screen.
// 
// Allows MANAGER/ADMIN to edit a project using ProjectForm prefilled with current data.
// Includes "Archive project" and "Restore project" actions with confirmation dialog.
// On success, invalidates providers and shows success snackbar.
// Shows server field errors on the form.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/network/api_exception.dart';
import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/projects/data/project_repository.dart';
import 'package:mobile_app/features/projects/providers/project_provider.dart';
import 'package:mobile_app/features/projects/widgets/project_form.dart';
import 'package:mobile_app/shared/models/project.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/app_snack_bar.dart';
import 'package:mobile_app/shared/widgets/glass_card.dart';
import 'package:mobile_app/shared/widgets/glass_dialogs.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  const EditProjectScreen({super.key, required this.projectId});

  final String projectId;

  static const String routeName = '/projects/:id/edit';

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  bool _isLoading = false;
  Map<String, String>? _fieldErrors;
  Project? _project;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(String name, String description) async {
    if (_project == null) return;

    setState(() {
      _isLoading = true;
      _fieldErrors = null;
    });

    try {
      final repository = ref.read(projectRepositoryProvider);
      final updatedProject = await repository.updateProject(
        id: _project!.id,
        name: name,
        description: description,
      );

      if (!mounted) return;

      // Invalidate providers to refresh project lists
      ref.invalidate(projectsProvider(null));
      ref.invalidate(projectsProvider(ProjectStatus.active));
      ref.invalidate(projectsProvider(ProjectStatus.archived));
      ref.invalidate(filteredProjectsProvider);
      ref.invalidate(projectProvider(_project!.id));

      // Update local project state
      setState(() {
        _project = updatedProject;
        _isLoading = false;
      });

      // Show success snackbar
      AppSnackBar.showSuccess(context, 'Project updated successfully');
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
      AppSnackBar.showError(context, 'Failed to update project: $e');
    }
  }

  Future<void> _toggleArchive() async {
    if (_project == null) return;

    final isArchived = _project!.status == ProjectStatus.archived;
    final newStatus = isArchived ? ProjectStatus.active : ProjectStatus.archived;
    
    final confirmed = await showConfirmDialog(
      context: context,
      title: isArchived ? 'Restore Project' : 'Archive Project',
      message: isArchived
          ? 'This project will be restored and available for new tasks.'
          : 'This project will be archived. No new tasks can be added to an archived project, but existing tasks will remain accessible.',
      confirmLabel: isArchived ? 'Restore' : 'Archive',
      destructive: !isArchived,
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(projectRepositoryProvider);
      final updatedProject = await repository.updateProject(
        id: _project!.id,
        status: newStatus,
      );

      if (!mounted) return;

      // Invalidate providers to refresh project lists
      ref.invalidate(projectsProvider(null));
      ref.invalidate(projectsProvider(ProjectStatus.active));
      ref.invalidate(projectsProvider(ProjectStatus.archived));
      ref.invalidate(filteredProjectsProvider);
      ref.invalidate(projectProvider(_project!.id));

      // Update local project state
      setState(() {
        _project = updatedProject;
        _isLoading = false;
      });

      // Show success snackbar
      AppSnackBar.showSuccess(
        context,
        isArchived ? 'Project restored successfully' : 'Project archived successfully',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppSnackBar.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppSnackBar.showError(context, 'Failed to update project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;

    // Watch project data
    final projectAsync = ref.watch(projectProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/projects/${widget.projectId}'),
        ),
      ),
      body: SafeArea(
        child: projectAsync.when(
          data: (project) {
            // Initialize project on first load
            _project ??= project;

            // Redirect non-manager/admin users
            if (!isManagerOrAdmin) {
              return Center(
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
                      'Only managers and admins can edit projects.',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Back to Project',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/projects/${widget.projectId}'),
                      fullWidth: false,
                    ),
                  ],
                ),
              );
            }

            final isArchived = project.status == ProjectStatus.archived;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Project form
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ProjectForm(
                      initialName: project.name,
                      initialDescription: project.description ?? '',
                      submitLabel: 'Save Changes',
                      isLoading: _isLoading,
                      nameFocusNode: _nameFocusNode,
                      descriptionFocusNode: _descriptionFocusNode,
                      onSubmit: _onSubmit,
                      fieldErrors: _fieldErrors,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Archive/Restore action
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              isArchived ? 'Restore Project' : 'Archive Project',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          isArchived
                              ? 'This project is archived. Restore it to allow new tasks to be added.'
                              : 'Archiving this project will prevent new tasks from being added. Existing tasks will remain accessible.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: isArchived ? 'Restore Project' : 'Archive Project',
                          variant: isArchived ? AppButtonVariant.primary : AppButtonVariant.secondary,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _toggleArchive,
                          leadingIcon: Icon(isArchived ? Icons.unarchive : Icons.archive),
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Failed to load project',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error.toString(),
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Retry',
                  variant: AppButtonVariant.primary,
                  onPressed: () => ref.invalidate(projectProvider(widget.projectId)),
                  fullWidth: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
