// Task data-layer repository.
//
// Talks to the backend task routes documented in
// backend/src/controllers/task.controller.js:
//   GET  /tasks/my              -> { tasks }
//   (with optional status query parameter: TODO, IN_PROGRESS, DONE)
//   GET  /tasks/:id             -> { task } (full shape with project, assignee, createdBy)
//   PATCH /tasks/:id/status     -> { task } (expects { status: 'TODO' | 'IN_PROGRESS' | 'DONE' })
//   POST /tasks                 -> { task } (create)
//   PATCH /tasks/:id            -> { task } (update)

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

  /// Creates a new task.
  ///
  /// POST /tasks with body { title, description, projectId, assigneeId, dueDate, priority }
  /// dueDate formatted as YYYY-MM-DD, null to clear.
  /// Returns the created task.
  Future<Task> createTask({
    required String title,
    required String description,
    required String projectId,
    String? assigneeId,
    DateTime? dueDate,
    required TaskPriority priority,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'projectId': projectId,
      'priority': priority.toServerValue(),
    };
    if (assigneeId != null && assigneeId.isNotEmpty) {
      data['assigneeId'] = assigneeId;
    }
    if (dueDate != null) {
      data['dueDate'] = _formatDateOnly(dueDate);
    } else {
      data['dueDate'] = null;
    }

    final response = await _apiClient.post(
      '/tasks',
      data: data,
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from POST /tasks',
      );
    }

    final taskJson = responseData['task'];
    if (taskJson is! Map) {
      throw ApiException(
        message: 'Unexpected response format from POST /tasks',
      );
    }

    return Task.fromJson(Map<String, dynamic>.from(taskJson));
  }

  /// Updates an existing task.
  ///
  /// PATCH /tasks/:id with body { title, description, assigneeId, dueDate, priority }
  /// dueDate formatted as YYYY-MM-DD, null to clear.
  /// Returns the updated task.
  Future<Task> updateTask({
    required String id,
    required String title,
    required String description,
    String? assigneeId,
    DateTime? dueDate,
    required TaskPriority priority,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority.toServerValue(),
    };
    if (assigneeId != null && assigneeId.isNotEmpty) {
      data['assigneeId'] = assigneeId;
    } else {
      data['assigneeId'] = null;
    }
    if (dueDate != null) {
      data['dueDate'] = _formatDateOnly(dueDate);
    } else {
      data['dueDate'] = null;
    }

    final response = await _apiClient.patch(
      '/tasks/$id',
      data: data,
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from PATCH /tasks/$id',
      );
    }

    final taskJson = responseData['task'];
    if (taskJson is! Map) {
      throw ApiException(
        message: 'Unexpected response format from PATCH /tasks/$id',
      );
    }

    return Task.fromJson(Map<String, dynamic>.from(taskJson));
  }

  /// Formats a [DateTime] as YYYY-MM-DD for backend.
  String _formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// Provider for [TaskRepository]. Wires the shared [ApiClient] together.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TaskRepository(apiClient);
});
