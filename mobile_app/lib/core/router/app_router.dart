// App router configuration using go_router.
//
// Provides a [Provider<GoRouter>] with all app routes and redirect logic
// based on the authentication state from [authProvider].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
import 'package:mobile_app/features/projects/screens/projects_screen.dart';
import 'package:mobile_app/features/tasks/screens/my_tasks_screen.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/shared/widgets/app_button.dart';
import 'package:mobile_app/shared/widgets/error_view.dart';
import 'package:mobile_app/core/theme/app_tokens.dart';

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
      // Project detail placeholder (Task 14)
      GoRoute(
        path: '/projects/:id',
        name: 'project-detail',
        builder: (context, state) => _ProjectDetailPlaceholder(projectId: state.pathParameters['id']!),
      ),
      // Project creation placeholder (Task 15)
      GoRoute(
        path: '/projects/new',
        name: 'project-create',
        builder: (context, state) => const _ProjectCreatePlaceholder(),
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
      // Check if location is one of the valid shell routes
      final validShellRoutes = [
        DashboardScreen.routeName,
        ProjectsScreen.routeName,
        MyTasksScreen.routeName,
        ProfileScreen.routeName,
      ];
      if (!validShellRoutes.contains(location)) {
        return homeRoute;
      }
      break;
  }

  // No redirect needed
  return null;
}

/// Placeholder for project detail screen (Task 14).
class _ProjectDetailPlaceholder extends StatelessWidget {
  const _ProjectDetailPlaceholder({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_outlined, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Project Detail',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Project ID: $projectId',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Back to Projects',
                variant: AppButtonVariant.primary,
                onPressed: () => context.go('/projects'),
                fullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder for project creation screen (Task 15).
class _ProjectCreatePlaceholder extends StatelessWidget {
  const _ProjectCreatePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline, size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Create Project',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Project creation form (Task 15)',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Back to Projects',
                variant: AppButtonVariant.primary,
                onPressed: () => context.go('/projects'),
                fullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}