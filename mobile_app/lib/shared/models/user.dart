// User domain models.
//
// Mirrors the JSON emitted by backend/src/controllers/user.controller.js and
// the User Sequelize model (backend/src/models/User.js), whose toJSON always
// produces a single canonical shape:
//   { id, name, email, role, status, createdAt }
//
// Backend ENUMs (UPPER-CASE):
//  * role:   'ADMIN' | 'MANAGER' | 'EMPLOYEE'  (nullable: PENDING users have
//            role: null, per allowNull: true, defaultValue: null)
//  * status: 'PENDING' | 'ACTIVE' | 'DEACTIVATED'
//
// NOTE: the backend README.md (master context) historically documents
// UserStatus as PENDING, ACTIVE, INACTIVE. The actual Sequelize ENUM is
// ENUM('PENDING','ACTIVE','DEACTIVATED') — these models match the real backend.

import 'package:flutter/foundation.dart';

/// Coerces a JSON value to a [String?]; non-string values become `null`.
String? _asString(dynamic value) => value is String ? value : null;

/// Parses an ISO-8601 timestamp defensively.
DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

/// The role of a [User], matching backend ENUM('ADMIN','MANAGER','EMPLOYEE').
///
/// The backend column is nullable (`allowNull: true`, `defaultValue: null`):
/// a PENDING user has `role: null`. [Role.fromServer] therefore returns
/// `null` for a null/unknown value, and [User.role] is nullable.
enum Role {
  admin,
  manager,
  employee;

  static Role? fromServer(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'ADMIN':
        return Role.admin;
      case 'MANAGER':
        return Role.manager;
      case 'EMPLOYEE':
        return Role.employee;
      default:
        return null;
    }
  }

  /// Converts to the UPPER-CASE server string.
  String toServerValue() {
    switch (this) {
      case Role.admin:
        return 'ADMIN';
      case Role.manager:
        return 'MANAGER';
      case Role.employee:
        return 'EMPLOYEE';
    }
  }

  /// Human-readable label for UI display.
  String get label {
    switch (this) {
      case Role.admin:
        return 'Admin';
      case Role.manager:
        return 'Manager';
      case Role.employee:
        return 'Employee';
    }
  }
}

/// The status of a [User], matching backend ENUM('PENDING','ACTIVE','DEACTIVATED').
///
/// Falls back to [UserStatus.pending] (the backend default) for a missing or
/// unrecognized value so parsing never throws on an unknown enum.
enum UserStatus {
  pending,
  active,
  deactivated;

  static UserStatus fromServer(String? value) {
    if (value == null) return UserStatus.pending;
    switch (value) {
      case 'PENDING':
        return UserStatus.pending;
      case 'ACTIVE':
        return UserStatus.active;
      case 'DEACTIVATED':
        return UserStatus.deactivated;
      default:
        return UserStatus.pending;
    }
  }

  String toServerValue() {
    switch (this) {
      case UserStatus.pending:
        return 'PENDING';
      case UserStatus.active:
        return 'ACTIVE';
      case UserStatus.deactivated:
        return 'DEACTIVATED';
    }
  }
}

/// A lightweight user reference `{ id, name }` (a partial User profile returned
/// by the backend when nesting users, e.g. a project's `owner`).
@immutable
class UserRef {
  const UserRef({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory UserRef.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
        "UserRef requires a non-null object containing 'id' and 'name'",
      );
    }
    final id = json['id'];
    final name = json['name'];
    if (id is! String) {
      throw FormatException(
        "UserRef 'id' is required and must be a String (was: $id)",
      );
    }
    if (name is! String) {
      throw FormatException(
        "UserRef 'name' is required and must be a String (was: $name)",
      );
    }
    return UserRef(id: id, name: name);
  }

  /// Parses a nullable nested `{ id, name }` object into a [UserRef].
  static UserRef? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UserRef.fromJson(json);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'UserRef(id: $id, name: $name)';
}

/// A user, matching the backend user response object (`User.toJSON`).
@immutable
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.status = UserStatus.pending,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final Role? role;
  final UserStatus status;
  final DateTime? createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException(
        "User 'id' is required and must be a String (was: $id)",
      );
    }
    final name = json['name'];
    if (name is! String) {
      throw FormatException(
        "User 'name' is required and must be a String (was: $name)",
      );
    }
    final email = json['email'];
    if (email is! String) {
      throw FormatException(
        "User 'email' is required and must be a String (was: $email)",
      );
    }
    return User(
      id: id,
      name: name,
      email: email,
      role: Role.fromServer(_asString(json['role'])),
      status: UserStatus.fromServer(_asString(json['status'])),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role?.toServerValue(),
        'status': status.toServerValue(),
        'createdAt': createdAt?.toUtc().toIso8601String(),
      };

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, role: $role, status: $status)';
}

/// A member of a project, matching the nested objects in `GET /projects/:id`
/// and the `members` array returned by `POST /projects/:id/members`.
@immutable
class ProjectMember {
  const ProjectMember({
    required this.id,
    required this.name,
    this.role,
  });

  final String id;
  final String name;
  final Role? role;

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException(
        "ProjectMember 'id' is required and must be a String (was: $id)",
      );
    }
    final name = json['name'];
    if (name is! String) {
      throw FormatException(
        "ProjectMember 'name' is required and must be a String (was: $name)",
      );
    }
    return ProjectMember(
      id: id,
      name: name,
      role: Role.fromServer(_asString(json['role'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role?.toServerValue(),
      };

  @override
  String toString() =>
      'ProjectMember(id: $id, name: $name, role: $role)';
}

/// A candidate for project membership, matching the objects in the
/// `users` array returned by GET /projects/candidates.
///
/// Candidates are ACTIVE users whose role is MANAGER or EMPLOYEE
/// (the server already filters out PENDING and DEACTIVATED users).
/// Only `id`, `name`, and `role` are returned — no email or status.
@immutable
class Candidate {
  const Candidate({
    required this.id,
    required this.name,
    this.role,
  });

  final String id;
  final String name;
  final Role? role;

  factory Candidate.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException(
        "Candidate 'id' is required and must be a String (was: $id)",
      );
    }
    final name = json['name'];
    if (name is! String) {
      throw FormatException(
        "Candidate 'name' is required and must be a String (was: $name)",
      );
    }
    return Candidate(
      id: id,
      name: name,
      role: Role.fromServer(_asString(json['role'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role?.toServerValue(),
      };

  @override
  String toString() => 'Candidate(id: $id, name: $name, role: $role)';
}
