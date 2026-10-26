// Project providers layer.
//
// Provides [FutureProvider.family] for projects filtered by status,
// with refresh capability.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/project.dart';
import '../data/project_repository.dart';

/// Provider for projects filtered by status.
/// Uses FutureProvider.family to allow different status filters.
final projectsProvider = FutureProvider.family<List<Project>, ProjectStatus?>(
  (ref, status) async {
    final repository = ref.read(projectRepositoryProvider);
    final response = await repository.getProjects(status: status);
    return response.projects;
  },
);

/// Provider for the current project status filter.
/// Default is null (All), but can be overridden to Active or Archived.
final projectStatusFilterProvider = StateProvider<ProjectStatus?>((ref) => null);

/// Combined provider that watches the filter and provides the matching projects.
/// This is the main provider used by the UI.
final filteredProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final status = ref.watch(projectStatusFilterProvider);
  final projectsAsync = ref.watch(projectsProvider(status));
  return projectsAsync.when(
    data: (projects) => projects,
    loading: () => throw StateError('loading'),
    error: (error, stack) => throw error,
  );
});