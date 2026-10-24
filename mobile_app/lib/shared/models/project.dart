// Project domain model.
//
// Mirrors the JSON emitted by backend/src/controllers/project.controller.js
// and the Project Sequelize model (backend/src/models/Project.js).
//
// Backend ENUM: status = 'ACTIVE' | 'ARCHIVED'.
//
// NOTE: the backend README.md (master context) historically documents
// ProjectStatus as ACTIVE, INACTIVE — the real Sequelize ENUM is
// ENUM('ACTIVE','ARCHIVED'). These models match the real backend.
//
// NOTE: the README shows a project response with a raw `ownerId` UUID field.
// The actual controllers return a nested `owner: { id, name }` object (a
// partial User with only id and name). This model exposes `owner` as a
// [UserRef] to match the real API shape, not the README's `ownerId`.
//
// Backend JSON shapes vary by endpoint, so Project.fromJson tolerates them:
//  * list   (GET /projects):      { id, name, description, status, owner?,
//                                  memberCount, taskCount: 0, createdAt }
//  * create (POST /projects):     { ..., owner?, memberCount, createdAt }
//                                  (no taskCount, no members)
//  * detail (GET /projects/:id):  { ..., owner?, members: [{id,name,role}],
//                                  createdAt }  (no memberCount/taskCount)

import 'package:flutter/foundation.dart';

import 'user.dart';

/// Coerces a JSON value to a [String?]; non-string values become `null`.
String? _asString(dynamic value) => value is String ? value : null;

/// Parses an ISO-8601 timestamp defensively.
DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

/// Coerces a JSON value to an [int?] tolerantly.
int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Project visibility status, matching backend ENUM('ACTIVE','ARCHIVED').
///
/// Falls back to [ProjectStatus.active] (the backend default) for a missing or
/// unrecognized value.
enum ProjectStatus {
  active,
  archived;

  static ProjectStatus fromServer(String? value) {
    if (value == null) return ProjectStatus.active;
    switch (value) {
      case 'ACTIVE':
        return ProjectStatus.active;
      case 'ARCHIVED':
        return ProjectStatus.archived;
      default:
        return ProjectStatus.active;
    }
  }

  /// Converts to the UPPER-CASE server string.
  String toServerValue() {
    switch (this) {
      case ProjectStatus.active:
        return 'ACTIVE';
      case ProjectStatus.archived:
        return 'ARCHIVED';
    }
  }
}

/// A project, matching the backend project response object.
@immutable
class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.status = ProjectStatus.active,
    this.owner,
    this.memberCount = 0,
    this.taskCount = 0,
    this.createdAt,
    this.members = const <ProjectMember>[],
  });

  final String id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final UserRef? owner;
  final int memberCount;
  final int taskCount;
  final DateTime? createdAt;
  final List<ProjectMember> members;

  factory Project.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException(
        "Project 'id' is required and must be a String (was: $id)",
      );
    }
    final name = json['name'];
    if (name is! String) {
      throw FormatException(
        "Project 'name' is required and must be a String (was: $name)",
      );
    }
    final membersRaw = json['members'];
    late final List<ProjectMember> members;
    if (membersRaw is List) {
      members = membersRaw
          .whereType<Map>()
          .map((m) => ProjectMember.fromJson(Map<String, dynamic>.from(m)))
          .toList(growable: false);
    } else {
      members = const <ProjectMember>[];
    }
    return Project(
      id: id,
      name: name,
      description: _asString(json['description']),
      status: ProjectStatus.fromServer(_asString(json['status'])),
      owner: UserRef.tryFromJson(
        json['owner'] is Map
            ? Map<String, dynamic>.from(json['owner'] as Map)
            : null,
      ),
      memberCount: _asInt(json['memberCount']) ?? 0,
      taskCount: _asInt(json['taskCount']) ?? 0,
      createdAt: _parseDateTime(json['createdAt']),
      members: members,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status.toServerValue(),
        'owner': owner?.toJson(),
        'memberCount': memberCount,
        'taskCount': taskCount,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'members': members.map((m) => m.toJson()).toList(),
      };

  @override
  String toString() => 'Project(id: $id, name: $name, status: $status, '
      'memberCount: $memberCount, taskCount: $taskCount)';
}
