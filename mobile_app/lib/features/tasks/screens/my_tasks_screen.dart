// My Tasks screen.
//
// Displays tasks assigned to the current employee with tabs for To Do, In Progress, Done.
// Shows task counts, pull-to-refresh, loading/error/empty states per tab.
// Tapping a card navigates to /tasks/:id (placeholder for Task 19).
// Overdue tasks appear first in each tab.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/theme/app_tokens.dart';
import 'package:employee_management/features/tasks/providers/task_provider.dart';
import 'package:employee_management/features/tasks/widgets/task_card.dart';
import 'package:employee_management/features/tasks/widgets/task_status_tabs.dart';
import 'package:employee_management/shared/models/task.dart';
import 'package:employee_management/shared/widgets/empty_view.dart';
import 'package:employee_management/shared/widgets/error_view.dart';
import 'package:employee_management/shared/widgets/loading_view.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  static const String routeName = '/my-tasks';

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TaskStatusTabs.all.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final selectedTab = TaskStatusTabs.all[_tabController.index];
      ref.read(myTasksFilterProvider.notifier).state = selectedTab.filterValue;
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(myTasksProvider);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(myTasksFilterProvider);
    final currentIndex = TaskStatusTabs.all.indexWhere(
      (tab) => tab.filterValue == currentFilter,
    );
    if (currentIndex != -1 && currentIndex != _tabController.index) {
      _tabController.animateTo(currentIndex);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: TabBarView(
                  controller: _tabController,
                  children: TaskStatusTabs.all.map((tab) {
                    return _buildTabContent(tab.filterValue);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.glassBorder, width: 1.0),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: TaskStatusTabs.all.map((tab) {
          final count = _getTabCount(tab.filterValue);
          return Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tab.label),
                  if (count > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _tabController.index ==
                                TaskStatusTabs.all.indexOf(tab)
                            ? AppColors.onPrimary.withValues(alpha: 0.2)
                            : AppColors.glassFillPressed,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index ==
                                  TaskStatusTabs.all.indexOf(tab)
                              ? AppColors.onPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
int _getTabCount(TaskStatus status) {
    final allTasksAsync = ref.watch(myTasksProvider);
    return allTasksAsync.when(
      data: (tasks) => tasks.where((t) => t.status == status).length,
      loading: () => 0,
      error: (_, _) => 0,
    );
  }

  Widget _buildTabContent(TaskStatus status) {
    final tasksAsync = ref.watch(filteredMyTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyView(status);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TaskCard(
                task: task,
                onTap: () {
                  // Navigate to task detail (placeholder for Task 19)
                  context.go('/tasks/${task.id}');
                },
              ),
            );
          },
        );
      },
      loading: () => const LoadingView(message: 'Loading tasks...'),
      error: (error, stackTrace) => ErrorView(
        title: 'Failed to load tasks',
        message: error.toString(),
        onRetry: _onRefresh,
      ),
    );
  }

  Widget _buildEmptyView(TaskStatus status) {
    String title;
    String? subtitle;
    IconData icon;

    switch (status) {
      case TaskStatus.todo:
        title = 'No tasks to do';
        subtitle = 'Tasks assigned to you will appear here';
        icon = Icons.checklist_outlined;
        break;
      case TaskStatus.inProgress:
        title = 'No tasks in progress';
        subtitle = 'Start working on a task to see it here';
        icon = Icons.hourglass_empty_outlined;
        break;
      case TaskStatus.done:
        title = 'No completed tasks';
        subtitle = 'Completed tasks will appear here';
        icon = Icons.task_alt_outlined;
        break;
    }

    return EmptyView(
      icon: icon,
      title: title,
      subtitle: subtitle,
    );
  }
}