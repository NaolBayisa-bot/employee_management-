// Task providers layer.
//
// Provides [FutureProvider] for my tasks fetched once and filtered on the client side,
// with refresh capability and a status filter.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/task.dart';
import '../data/task_repository.dart';

/// Provider for all my tasks (fetched once, filtered client-side).
/// This is simpler than Family providers since we fetch all statuses at once.
final myTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getMyTasks(); // No status filter = fetch all
});

/// Provider for the current task status filter (tab selection).
/// Default is null (show all), but UI will use tabs to filter.
final myTasksFilterProvider = StateProvider<TaskStatus?>((ref) => null);

/// Provider that filters tasks by the selected status and sorts overdue tasks first.
/// This is the main provider used by the UI.
final filteredMyTasksProvider = FutureProvider<List<Task>>((ref) async {
  final allTasksAsync = ref.watch(myTasksProvider);
  final filter = ref.watch(myTasksFilterProvider);

  return allTasksAsync.when(
    data: (tasks) {
      // Filter by status if a filter is set
      final filtered = filter != null
          ? tasks.where((t) => t.status == filter).toList()
          : tasks;

      // Sort: overdue tasks first, then by due date (ascending), then by createdAt (descending)
      filtered.sort((a, b) {
        // Overdue tasks come first
        final aOverdue = a.isOverdue;
        final bOverdue = b.isOverdue;

        if (aOverdue && !bOverdue) return -1;
        if (!aOverdue && bOverdue) return 1;

        // If both overdue or both not overdue, sort by due date
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;

        // Fallback: sort by createdAt descending (newer first)
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return 0;
      });

      return filtered;
    },
    loading: () => throw StateError('loading'),
    error: (error, stack) => throw error,
  );
});

/// Provider for a single task by ID with full details.
/// Uses autoDispose to release the task when the screen is popped.
final taskProvider = FutureProvider.autoDispose.family<Task, String>((ref, taskId) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTask(taskId);
});

/// Notifier for updating task status.
/// Handles the update, invalidates related providers, and provides loading/error state.
class TaskStatusUpdater extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Updates the task status and invalidates related providers.
  /// Returns the updated task on success, throws on failure.
  Future<Task> updateStatus(String taskId, TaskStatus newStatus) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(taskRepositoryProvider);
      final updatedTask = await repository.updateStatus(taskId, newStatus);

      // Invalidate providers to refresh UI
      ref.invalidate(myTasksProvider);
      ref.invalidate(filteredMyTasksProvider);
      ref.invalidate(taskProvider(taskId));
      // Also invalidate project tasks if this task belongs to a project
      // (projectTasksProvider is in project_provider.dart)

      state = const AsyncData(null);
      return updatedTask;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

/// Provider for the task status updater notifier.
final taskStatusUpdaterProvider = AutoDisposeNotifierProvider<TaskStatusUpdater, AsyncValue<void>>(
  TaskStatusUpdater.new,
);

/// Notifier for creating a new task.
/// Handles the creation, invalidates related providers, and provides loading/error state.
class TaskCreator extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Creates a new task and invalidates related providers.
  /// Returns the created task on success, throws on failure.
  Future<Task> createTask({
    required String title,
    required String description,
    required String projectId,
    String? assigneeId,
    DateTime? dueDate,
    required TaskPriority priority,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(taskRepositoryProvider);
      final createdTask = await repository.createTask(
        title: title,
        description: description,
        projectId: projectId,
        assigneeId: assigneeId,
        dueDate: dueDate,
        priority: priority,
      );

      // Invalidate providers to refresh UI
      ref.invalidate(myTasksProvider);
      ref.invalidate(filteredMyTasksProvider);
      // Note: projectTasksProvider is in project_provider.dart, invalidated via project detail screen

      state = const AsyncData(null);
      return createdTask;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

/// Provider for the task creator notifier.
final createTaskProvider = AutoDisposeNotifierProvider<TaskCreator, AsyncValue<void>>(
  TaskCreator.new,
);

/// Notifier for updating an existing task.
/// Handles the update, invalidates related providers, and provides loading/error state.
class TaskUpdater extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Updates an existing task and invalidates related providers.
  /// Returns the updated task on success, throws on failure.
  Future<Task> updateTask({
    required String id,
    required String title,
    required String description,
    String? assigneeId,
    DateTime? dueDate,
    required TaskPriority priority,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(taskRepositoryProvider);
      final updatedTask = await repository.updateTask(
        id: id,
        title: title,
        description: description,
        assigneeId: assigneeId,
        dueDate: dueDate,
        priority: priority,
      );

      // Invalidate providers to refresh UI
      ref.invalidate(myTasksProvider);
      ref.invalidate(filteredMyTasksProvider);
      ref.invalidate(taskProvider(id));
      // Note: projectTasksProvider is in project_provider.dart

      state = const AsyncData(null);
      return updatedTask;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

/// Provider for the task updater notifier.
final updateTaskProvider = AutoDisposeNotifierProvider<TaskUpdater, AsyncValue<void>>(
  TaskUpdater.new,
);
