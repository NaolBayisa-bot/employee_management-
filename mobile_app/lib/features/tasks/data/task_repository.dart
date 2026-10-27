// Task data-layer repository.
//
// Talks to the backend task routes documented in
// backend/src/controllers/task.controller.js:
//   GET  /tasks/my              -> { tasks }
//   (with optional status query parameter: TODO, IN_PROGRESS, DONE)
//   GET  /tasks/:id             -> { task } (full shape with project, assignee, createdBy)
//   PATCH /tasks/:id/status     -> { task } (expects { status: 'TODO' | 'IN_PROGRESS' | 'DONE' })

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/task.dart';

/// Repository for task operations against the TaskApp backend.
class TaskRepository {
  TaskRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches tasks assigned to the current user with optional status filter.
  ///
  /// GET /tasks/my with optional status query parameter.
  /// Returns list of tasks (no assignee/createdBy/project nested objects in list endpoint).
  Future<List<Task>> getMyTasks({TaskStatus? status}) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) {
      queryParameters['status'] = status.toServerValue();
    }

    final response = await _apiClient.get(
      '/tasks/my',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from /tasks/my',
      );
    }

    final tasksRaw = data['tasks'];
    if (tasksRaw is! List) {
      return const <Task>[];
    }

    return tasksRaw
        .whereType<Map>()
        .map((m) => Task.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  /// Fetches a single task by ID with full details.
  ///
  /// GET /tasks/:id
  /// Returns full task shape including project, assignee, createdBy.
  Future<Task> getTask(String id) async {
    final response = await _apiClient.get('/tasks/$id');

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from /tasks/$id',
      );
    }

    final taskJson = data['task'];
    if (taskJson is! Map) {
      throw ApiException(
        message: 'Unexpected response format from /tasks/$id',
      );
    }

    return Task.fromJson(Map<String, dynamic>.from(taskJson));
  }

  /// Updates the status of a task.
  ///
  /// PATCH /tasks/:id/status with body { status }
  /// Returns the updated task.
  Future<Task> updateStatus(String id, TaskStatus status) async {
    final response = await _apiClient.patch(
      '/tasks/$id/status',
      data: {'status': status.toServerValue()},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from PATCH /tasks/$id/status',
      );
    }

    final taskJson = data['task'];
    if (taskJson is! Map) {
      throw ApiException(
        message: 'Unexpected response format from PATCH /tasks/$id/status',
      );
    }

    return Task.fromJson(Map<String, dynamic>.from(taskJson));
  }
}

/// Provider for [TaskRepository]. Wires the shared [ApiClient] together.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TaskRepository(apiClient);
});