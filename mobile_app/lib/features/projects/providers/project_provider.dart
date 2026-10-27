// Project providers layer.
//
// Provides [FutureProvider.family] for projects filtered by status,
// with refresh capability.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/project.dart';
import '../../../shared/models/task.dart';
import '../../../shared/models/user.dart';
import '../data/project_repository.dart';

/// Provider for projects filtered by status.
/// Uses FutureProvider.family to allow different status filters.
final projectsProvider = FutureProvider.family<List<Project>, ProjectStatus?>((
  ref,
  status,
) async {
  final repository = ref.read(projectRepositoryProvider);
  final response = await repository.getProjects(status: status);
  return response.projects;
});

/// Provider for the current project status filter.
/// Default is null (All), but can be overridden to Active or Archived.
final projectStatusFilterProvider = StateProvider<ProjectStatus?>(
  (ref) => null,
);

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

/// Provider for a single project by ID.
final projectProvider = FutureProvider.family<Project, String>((
  ref,
  projectId,
) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getProject(projectId);
});

/// Provider for project tasks by project ID.
final projectTasksProvider = FutureProvider.family<List<Task>, String>((
  ref,
  projectId,
) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getProjectTasks(projectId);
});

/// Provider for candidate users (searchable).
/// Uses FutureProvider.autoDispose.family so that results for a
/// particular search term are released when the screen is popped.
/// The [search] parameter is an empty string for "no filter" and a
/// non-empty string for a name search (debounced on the client side).
final candidatesProvider =
    FutureProvider.autoDispose.family<List<Candidate>, String>((
  ref,
  search,
) async {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getCandidates(search: search);
});
