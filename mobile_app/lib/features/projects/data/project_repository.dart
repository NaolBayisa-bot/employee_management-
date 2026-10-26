// Project data-layer repository.
//
// Talks to the backend project routes documented in
// backend/src/controllers/project.controller.js and backend/README.md:
//   GET  /projects              -> { projects, page, limit, total, totalPages }
//   (with optional status query parameter: ACTIVE, ARCHIVED)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/project.dart';

/// Paginated project list response.
@immutable
class ProjectListResponse {
  const ProjectListResponse({
    required this.projects,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<Project> projects;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    final projectsRaw = json['projects'];
    late final List<Project> projects;
    if (projectsRaw is List) {
      projects = projectsRaw
          .whereType<Map>()
          .map((m) => Project.fromJson(Map<String, dynamic>.from(m)))
          .toList(growable: false);
    } else {
      projects = const <Project>[];
    }
    return ProjectListResponse(
      projects: projects,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

/// Repository for project operations against the TaskApp backend.
class ProjectRepository {
  ProjectRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches projects with optional status filter.
  ///
  /// GET /projects with optional status query parameter.
  /// Returns paginated list of projects.
  Future<ProjectListResponse> getProjects({
    ProjectStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      queryParameters['status'] = status.toServerValue();
    }

    final response = await _apiClient.get(
      '/projects',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from /projects',
      );
    }

    return ProjectListResponse.fromJson(data);
  }
}

/// Provider for [ProjectRepository]. Wires the shared [ApiClient] together.
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProjectRepository(apiClient);
});