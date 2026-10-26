// Projects list screen.
//
// Displays projects with filtering by status (Active, Archived, All),
// pull-to-refresh, loading/error/empty states.
// FAB for creating new projects (MANAGER/ADMIN only).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/projects/providers/project_provider.dart';
import 'package:mobile_app/features/projects/widgets/project_card.dart';
import 'package:mobile_app/features/projects/widgets/project_status_filter.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/empty_view.dart';
import 'package:mobile_app/shared/widgets/error_view.dart';
import 'package:mobile_app/shared/widgets/loading_view.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  static const String routeName = '/projects';

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Invalidate the filtered projects provider to trigger a fresh fetch
    ref.invalidate(filteredProjectsProvider);
    // Also invalidate the family provider with current filter
    final status = ref.read(projectStatusFilterProvider);
    ref.invalidate(projectsProvider(status));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;
    final statusFilter = ref.watch(projectStatusFilterProvider);

    return Scaffold(
      // FAB for creating new project (MANAGER/ADMIN only)
      floatingActionButton: isManagerOrAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/projects/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 4,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Status filter bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: ProjectStatusFilter(
                selected: statusFilter,
                onChanged: (newStatus) {
                  ref.read(projectStatusFilterProvider.notifier).state = newStatus;
                },
              ),
            ),
            // Projects list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: _buildProjectsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    final projectsAsync = ref.watch(filteredProjectsProvider);

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return _buildEmptyView(ref.read(authProvider).valueOrNull);
        }
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ProjectCard(
                project: project,
                onTap: () => context.go('/projects/${project.id}'),
              ),
            );
          },
        );
      },
      loading: () => const LoadingView(message: 'Loading projects...'),
      error: (error, stackTrace) => ErrorView(
        title: 'Failed to load projects',
        message: error.toString(),
        onRetry: _onRefresh,
      ),
    );
  }

  Widget _buildEmptyView(User? user) {
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;
    final statusFilter = ref.watch(projectStatusFilterProvider);

    String title;
    String? subtitle;
    IconData icon;

    if (isManagerOrAdmin) {
      title = 'No projects yet';
      subtitle = 'Create your first project to get started';
      icon = Icons.folder_open_outlined;
    } else {
      title = 'No projects found';
      subtitle = 'You have not been added to any project yet';
      icon = Icons.inbox_outlined;
    }

    // Add filter context to subtitle
    if (statusFilter != null) {
      subtitle = '$subtitle (${statusFilter.toServerValue()})';
    }

    return EmptyView(
      icon: icon,
      title: title,
      subtitle: subtitle,
      action: isManagerOrAdmin
          ? AppButton(
              label: 'Create Project',
              variant: AppButtonVariant.primary,
              onPressed: () => context.go('/projects/new'),
              fullWidth: false,
            )
          : null,
    );
  }
}

