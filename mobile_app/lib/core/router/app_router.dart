// App router configuration using go_router.
//
// Provides a [Provider<GoRouter>] with all app routes and redirect logic
// based on the authentication state from [authProvider].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/features/admin/screens/dashboard_screen.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/auth/screens/deactivated_screen.dart';
import 'package:mobile_app/features/auth/screens/login_screen.dart';
import 'package:mobile_app/features/auth/screens/register_screen.dart';
import 'package:mobile_app/features/auth/screens/splash_screen.dart';
import 'package:mobile_app/features/auth/screens/waiting_approval_screen.dart';
import 'package:mobile_app/features/design_preview/design_preview_screen.dart';
import 'package:mobile_app/features/home/screens/main_shell.dart';
import 'package:mobile_app/features/profile/screens/profile_screen.dart';
import 'package:mobile_app/features/projects/screens/add_members_screen.dart';
import 'package:mobile_app/features/projects/screens/create_project_screen.dart';
import 'package:mobile_app/features/projects/screens/edit_project_screen.dart';
import 'package:mobile_app/features/projects/screens/project_detail_screen.dart';
import 'package:mobile_app/features/projects/screens/projects_screen.dart';
import 'package:mobile_app/features/tasks/screens/create_task_screen.dart';
import 'package:mobile_app/features/tasks/screens/edit_task_screen.dart';
import 'package:mobile_app/features/tasks/screens/my_tasks_screen.dart';
import 'package:mobile_app/features/tasks/screens/task_detail_screen.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/error_view.dart';

/// Provider for the [GoRouter] instance.
/// Listens to [authProvider] for authentication state changes and redirects accordingly.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state to trigger router refresh on changes
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    // Use a closure to capture the current authState for redirect
    redirect: (context, state) => _redirectLogic(authState, state.matchedLocation),
    routes: [
      // Splash screen - shown while auth state is loading
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Login screen
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Register screen
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Waiting for approval screen (PENDING users)
      GoRoute(
        path: '/waiting',
        name: 'waiting',
        builder: (context, state) => const WaitingApprovalScreen(),
      ),
      // Deactivated account screen
      GoRoute(
        path: '/deactivated',
        name: 'deactivated',
        builder: (context, state) => const DeactivatedScreen(),
      ),
      // Main shell with role-based tabs (ACTIVE users)
      buildMainShellRoute(),
      // Project creation (Task 15) - must come before /projects/:id to avoid
      // 'new' being captured as the :id parameter
      GoRoute(
        path: '/projects/new',
        name: 'project-create',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      // Project detail (Task 14)
      GoRoute(
        path: '/projects/:id',
        name: 'project-detail',
        builder: (context, state) => ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      // Add members (Task 16) - must come before /projects/:id/edit? No:
      // /projects/:id/members/add is a sub-route of /projects/:id, but
      // go_router matches routes in order; since /projects/:id matches first,
      // we register /projects/:id/members/add before /projects/:id to avoid
      // "members" being captured as the :id parameter.
      GoRoute(
        path: '/projects/:id/members/add',
        name: 'project-add-members',
        builder: (context, state) => AddMembersScreen(
          projectId: state.pathParameters['id']!,
        ),
      ),
      // Project edit (Task 15)
      GoRoute(
        path: '/projects/:id/edit',
        name: 'project-edit',
        builder: (context, state) => EditProjectScreen(projectId: state.pathParameters['id']!),
      ),
      // Task detail (Task 19)
      GoRoute(
        path: '/tasks/:id',
        name: 'task-detail',
        builder: (context, state) => TaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      // Create task (Task 21) - must come before /tasks/:id to avoid :id capturing "new"
      GoRoute(
        path: '/projects/:projectId/tasks/new',
        name: 'task-create',
        builder: (context, state) => CreateTaskScreen(projectId: state.pathParameters['projectId']!),
      ),
      // Edit task (Task 21)
      GoRoute(
        path: '/tasks/:id/edit',
        name: 'task-edit',
        builder: (context, state) => EditTaskScreen(taskId: state.pathParameters['id']!),
      ),
      // Design preview gallery (debug only)
      if (const bool.fromEnvironment('dart.vm.product') == false)
        GoRoute(
          path: DesignPreviewScreen.routeName,
          name: 'design-preview',
          builder: (context, state) => const DesignPreviewScreen(),
        ),
    ],
    // Error page builder for route-level errors (e.g., 404)
    errorBuilder: (context, state) => Scaffold(
      body: SafeArea(
        child: ErrorView(
          title: 'Page Not Found',
          message: 'The page you are looking for does not exist.',
          onRetry: () => context.go(_getHomeRouteForRole(
            (ref.read(authProvider).valueOrNull)?.role ?? Role.employee,
          )),
        ),
      ),
    ),
  );
});

/// Returns the home route path for a given role (first tab).
String _getHomeRouteForRole(Role role) {
  switch (role) {
    case Role.admin:
      return DashboardScreen.routeName; // '/dashboard'
    case Role.manager:
      return ProjectsScreen.routeName; // '/projects'
    case Role.employee:
      return MyTasksScreen.routeName; // '/my-tasks'
  }
}

/// Core redirect logic based on authentication state and user status.
///
/// Rules:
/// - auth loading (AsyncLoading) -> /splash
/// - auth error (AsyncError, network failure) -> null (let ErrorView handle it at current location)
/// - logged out (AsyncData(null)) -> /login (allow /register)
/// - PENDING -> /waiting
/// - DEACTIVATED -> /deactivated
/// - ACTIVE -> first tab route based on role
/// - Logged-in users can never access /login, /register, /waiting
String? _redirectLogic(AsyncValue<User?> authState, String location) {
  // 1. Auth is loading -> show splash
  if (authState is AsyncLoading) {
    return location == '/splash' ? null : '/splash';
  }

  // 2. Auth error (network failure on restore) -> don't redirect, let the UI show ErrorView
  // We return null to stay at current location and let the error UI handle it
  if (authState is AsyncError) {
    return null;
  }

  final user = authState.valueOrNull;

  // 3. Not logged in
  if (user == null) {
    // Allow access to login and register
    if (location == '/login' || location == '/register') {
      return null;
    }
    // Redirect everything else to login
    return '/login';
  }

  // 4. Logged in - guard auth routes (login, register, waiting)
  // Logged-in users should never see these
  if (location == '/login' || location == '/register' || location == '/waiting') {
    // Redirect based on user status
    switch (user.status) {
      case UserStatus.pending:
        return '/waiting';
      case UserStatus.deactivated:
        return '/deactivated';
      case UserStatus.active:
        return _getHomeRouteForRole(user.role ?? Role.employee);
    }
  }

  // 5. Status-based redirects for logged-in users
  switch (user.status) {
    case UserStatus.pending:
      if (location != '/waiting') return '/waiting';
      break;
    case UserStatus.deactivated:
      if (location != '/deactivated') return '/deactivated';
      break;
    case UserStatus.active:
      final homeRoute = _getHomeRouteForRole(user.role ?? Role.employee);
      // Check if location is one of the valid shell routes or a sub-route
      final validShellRoutes = [
        DashboardScreen.routeName,
        ProjectsScreen.routeName,
        MyTasksScreen.routeName,
        ProfileScreen.routeName,
        TaskDetailScreen.routeName,
        CreateTaskScreen.routeName,
        EditTaskScreen.routeName,
      ];
      // Allow exact matches or sub-routes (e.g., /projects/new, /projects/:id/edit)
      final isValidRoute = validShellRoutes.any(
        (route) => location == route || location.startsWith('$route/'),
      );
      if (!isValidRoute) {
        return homeRoute;
      }
      break;
  }

  // No redirect needed
  return null;
}