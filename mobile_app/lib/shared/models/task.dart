// Task domain models.
//
// Mirrors the JSON emitted by backend/src/controllers/task.controller.js and
// the Task Sequelize model (backend/src/models/Task.js).
//
// Backend ENUMs (UPPER-CASE):
//  * status:   'TODO' | 'IN_PROGRESS' | 'DONE'
//  * priority: 'LOW' | 'MEDIUM' | 'HIGH'
//
// The `dueDate` column is Sequelize DATEONLY, serialized as "YYYY-MM-DD"
// (e.g. "2024-01-20") — NOT an ISO datetime. [Task.fromJson] parses it as a
// local date with no time-zone shift.
//
// NOTE: the backend README.md (master context) historically documents
// TaskPriority as LOW, MEDIUM, HIGH, CRITICAL and shows dueDate as an ISO
// timestamp. The real model is ENUM('LOW','MEDIUM','HIGH') with no CRITICAL,
// and dueDate is DATEONLY. These models match the real backend.
//
// Backend JSON shapes vary by endpoint, so Task.fromJson tolerates them:
//  * list "my" (GET /tasks/my):          no assignee/createdBy/project nested
//                                        objects (only assigneeId/createdById)
//  * list "project" (GET /projects/:id/tasks): has assignee; no project/createdBy
//  * detail/create/update (GET/POST/PATCH /tasks/:id): full shape incl.
//    project, assignee, createdBy
// Backend-only scalar fields assigneeId, createdById, updatedAt are tolerated
// and intentionally not modeled.

import 'package:flutter/foundation.dart';

import 'user.dart';

/// Coerces a JSON value to a [String?]; non-string values become `null`.
String? _asString(dynamic value) => value is String ? value : null;

/// Parses an ISO-8601 timestamp defensively.
DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

/// Parses a backend DATEONLY value ("YYYY-MM-DD") as a local date with no
/// time-zone shift.
///
/// Tolerates a full ISO datetime by taking just the leading date portion,
/// which keeps `isOverdue` comparisons correct regardless of the format the
/// server emits. Returns `null` for absent/null/unparseable values.
DateTime? _parseDueDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  final datePart = value.length >= 10 ? value.substring(0, 10) : value;
  final parts = datePart.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  // Constructing with year/month/day yields a local-time date (no offset).
  return DateTime(y, m, d);
}

/// Formats a local [DateTime] as a backend DATEONLY string ("YYYY-MM-DD").
String _formatDateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// The status of a [Task], matching backend ENUM('TODO','IN_PROGRESS','DONE').
///
/// Tolerant: a missing/null/unknown value falls back to [TaskStatus.todo], the
/// backend default, so parsing never throws on an unknown enum.
enum TaskStatus {
  todo,
  inProgress,
  done;

  static TaskStatus fromServer(String? value) {
    if (value == null) return TaskStatus.todo;
    switch (value) {
      case 'TODO':
        return TaskStatus.todo;
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'DONE':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  /// Converts to the UPPER-CASE server string.
  String toServerValue() {
    switch (this) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  /// Human-readable display label for the UI (not a server value).
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To do';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.done:
        return 'Done';
    }
  }
}

/// The priority of a [Task], matching backend ENUM('LOW','MEDIUM','HIGH').
///
/// Tolerant: a missing/null/unknown value falls back to [TaskPriority.medium],
/// the backend default. The real backend has no `CRITICAL`.
enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromServer(String? value) {
    if (value == null) return TaskPriority.medium;
    switch (value) {
      case 'LOW':
        return TaskPriority.low;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'HIGH':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }

  /// Converts to the UPPER-CASE server string.
  String toServerValue() {
    switch (this) {
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.high:
        return 'HIGH';
    }
  }

  /// Human-readable display label for the UI (not a server value).
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

/// A lightweight project reference `{ id, name }` returned inside a task.
@immutable
class ProjectRef {
  const ProjectRef({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory ProjectRef.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
        "ProjectRef requires a non-null object containing 'id' and 'name'",
      );
    }
    final id = json['id'];
    final name = json['name'];
    if (id is! String) {
      throw FormatException(
        "ProjectRef 'id' is required and must be a String (was: $id)",
      );
    }
    if (name is! String) {
      throw FormatException(
        "ProjectRef 'name' is required and must be a String (was: $name)",
      );
    }
    return ProjectRef(id: id, name: name);
  }

  /// Parses a nullable nested `{ id, name }` object into a [ProjectRef].
  static ProjectRef? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ProjectRef.fromJson(json);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'ProjectRef(id: $id, name: $name)';
}

/// A task, matching the backend task response object.
@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    required this.projectId,
    this.project,
    this.assignee,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String projectId;
  final ProjectRef? project;
  final UserRef? assignee;
  final UserRef? createdBy;
  final DateTime? createdAt;

  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException(
        "Task 'id' is required and must be a String (was: $id)",
      );
    }
    final title = json['title'];
    if (title is! String) {
      throw FormatException(
        "Task 'title' is required and must be a String (was: $title)",
      );
    }
    final projectId = json['projectId'];
    if (projectId is! String) {
      throw FormatException(
        "Task 'projectId' is required and must be a String (was: $projectId)",
      );
    }
    return Task(
      id: id,
      title: title,
      description: _asString(json['description']),
      status: TaskStatus.fromServer(_asString(json['status'])),
      priority: TaskPriority.fromServer(_asString(json['priority'])),
      dueDate: _parseDueDate(json['dueDate']),
      projectId: projectId,
      project: ProjectRef.tryFromJson(
        json['project'] is Map
            ? Map<String, dynamic>.from(json['project'] as Map)
            : null,
      ),
      assignee: UserRef.tryFromJson(
        json['assignee'] is Map
            ? Map<String, dynamic>.from(json['assignee'] as Map)
            : null,
      ),
      createdBy: UserRef.tryFromJson(
        json['createdBy'] is Map
            ? Map<String, dynamic>.from(json['createdBy'] as Map)
            : null,
      ),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.toServerValue(),
        'priority': priority.toServerValue(),
        'projectId': projectId,
        'dueDate': dueDate == null ? null : _formatDateOnly(dueDate!),
        'project': project?.toJson(),
        'assignee': assignee?.toJson(),
        'createdBy': createdBy?.toJson(),
        'createdAt': createdAt?.toUtc().toIso8601String(),
      };

  /// True when the task is due before today and is not yet [TaskStatus.done].
  ///
  /// A task whose [dueDate] falls on today is not overdue. A [done] task is
  /// never overdue. A task with no [dueDate] is never overdue.
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isBefore(today);
  }

  @override
  String toString() => 'Task(id: $id, title: $title, projectId: $projectId)';
}
