// Project detail screen.
//
// Displays full project information with members and tasks.
// MANAGER/ADMIN see "Add member", "+ New task", and "Edit" actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app/core/theme/app_tokens.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/projects/providers/project_provider.dart';
import 'package:mobile_app/features/projects/widgets/member_avatar_stack.dart';
import 'package:mobile_app/features/projects/widgets/member_tile.dart';
import 'package:mobile_app/features/tasks/widgets/task_list_tile.dart';
import 'package:mobile_app/shared/models/project.dart';
import 'package:mobile_app/shared/models/task.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/empty_view.dart';
import 'package:mobile_app/shared/widgets/error_view.dart';
import 'package:mobile_app/shared/widgets/loading_view.dart';
import 'package:mobile_app/shared/widgets/section_header.dart';
import 'package:mobile_app/shared/widgets/status_chip.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  static const String routeName = '/projects/:id';

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(projectProvider(widget.projectId));
    ref.invalidate(projectTasksProvider(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final isManagerOrAdmin = user?.role == Role.manager || user?.role == Role.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
        actions: isManagerOrAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/projects/${widget.projectId}/edit'),
                  tooltip: 'Edit project',
                ),
              ]
            : null,
      ),
      floatingActionButton: isManagerOrAdmin
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'addTask',
                  onPressed: () => context.go('/projects/${widget.projectId}/tasks/new'),
                  icon: const Icon(Icons.add_task),
                  label: const Text('New Task'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                FloatingActionButton.extended(
                  heroTag: 'addMember',
                  onPressed: () => context.go('/projects/${widget.projectId}/members/add'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Member'),
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final projectAsync = ref.watch(projectProvider(widget.projectId));
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));

    return projectAsync.when(
      data: (project) => _buildProjectContent(project, tasksAsync),
      loading: () => const LoadingView(message: 'Loading project...'),
      error: (error, stackTrace) => _buildErrorView(error, isProjectError: true),
    );
  }

  Widget _buildProjectContent(Project project, AsyncValue<List<Task>> tasksAsync) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Project header
        SliverToBoxAdapter(
          child: _buildProjectHeader(project),
        ),

        // Members section
        SliverToBoxAdapter(
          child: _buildMembersSection(project),
        ),

        // Tasks section
        SliverToBoxAdapter(
          child: _buildTasksSection(tasksAsync),
        ),
      ],
    );
  }

  Widget _buildProjectHeader(Project project) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (project.status == ProjectStatus.archived) ...[
                const SizedBox(width: AppSpacing.sm),
                StatusChip.projectStatus(ProjectStatus.archived),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (project.description != null && project.description!.isNotEmpty)
            Text(
              project.description!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            )
          else
            Text(
              'No description',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Owner: ${project.owner?.name ?? 'Unknown'}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildStat(
                Icons.group_outlined,
                '${project.memberCount} members',
              ),
              const SizedBox(width: AppSpacing.lg),
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

  Widget _buildMembersSection(Project project) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Members'),
          const SizedBox(height: AppSpacing.md),
          if (project.members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: EmptyView(
                icon: Icons.group_outlined,
                title: 'No members',
                subtitle: 'No members have been added to this project yet',
              ),
            )
          else
            Column(
              children: [
                MemberAvatarStack(
                  members: project.members,
                  max: 4,
                ),
                const SizedBox(height: AppSpacing.lg),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: project.members.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.divider, height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final member = project.members[index];
                    return MemberTile(
                      member: member,
                      trailing: const Icon(Icons.more_vert, size: 18),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(AsyncValue<List<Task>> tasksAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Tasks'),
          const SizedBox(height: AppSpacing.md),
          tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return EmptyView(
                  icon: Icons.assignment_outlined,
                  title: 'No tasks',
                  subtitle: 'No tasks have been created for this project yet',
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.divider, height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskListTile(
                    task: task,
                    onTap: () => context.go('/tasks/${task.id}'),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                  );
                },
              );
            },
            loading: () => const LoadingView(message: 'Loading tasks...'),
            error: (error, stackTrace) => _buildErrorView(error, isProjectError: false),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error, {required bool isProjectError}) {
    return ErrorView(
      title: isProjectError ? 'Failed to load project' : 'Failed to load tasks',
      message: error.toString(),
      onRetry: _onRefresh,
    );
  }
}
