// Main shell with role-based tabs using StatefulShellRoute.
//
// Provides a bottom navigation bar with tabs that preserve state when switching.
// Tab order varies by user role:
// - EMPLOYEE: My Tasks, Projects, Profile
// - MANAGER: Projects, My Tasks, Profile
// - ADMIN: Dashboard, Projects, My Tasks, Profile

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:employee_management/features/admin/screens/dashboard_screen.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/profile/screens/profile_screen.dart';
import 'package:employee_management/features/projects/screens/projects_screen.dart';
import 'package:employee_management/features/tasks/screens/my_tasks_screen.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/glass_navigation_bar.dart';

/// Main shell widget with role-based navigation tabs.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final role = user?.role ?? Role.employee;

    // Get the tab configuration for the current role
    final tabs = _getTabsForRole(role);

    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: GlassNavigationBar(
        destinations: tabs
            .map((tab) => GlassNavigationDestination(
                  icon: tab.icon,
                  selectedIcon: tab.selectedIcon,
                  label: tab.label,
                ))
            .toList(),
        selectedIndex: widget.navigationShell.currentIndex,
        onSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  List<_TabConfig> _getTabsForRole(Role role) {
    switch (role) {
      case Role.admin:
        return [
          _TabConfig(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          _TabConfig(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: 'Projects',
          ),
          _TabConfig(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: 'My Tasks',
          ),
          _TabConfig(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case Role.manager:
        return [
          _TabConfig(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: 'Projects',
          ),
          _TabConfig(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: 'My Tasks',
          ),
          _TabConfig(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case Role.employee:
        return [
          _TabConfig(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: 'My Tasks',
          ),
          _TabConfig(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: 'Projects',
          ),
          _TabConfig(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ];
    }
  }
}

/// Internal tab configuration.
class _TabConfig {
  const _TabConfig({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
}
/// Builds the StatefulShellRoute for the main app shell.
///
/// The route structure:
/// - /home (shell) -> branches for each tab
///   - Admin: /dashboard, /projects, /my-tasks, /profile
///   - Manager: /projects, /my-tasks, /profile
///   - Employee: /my-tasks, /projects, /profile
StatefulShellRoute buildMainShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return MainShell(navigationShell: navigationShell);
    },
    branches: [
      // Branch 0: Dashboard (Admin only)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: DashboardScreen.routeName,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      ),
      // Branch 1: Projects
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: ProjectsScreen.routeName,
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
        ],
      ),
      // Branch 2: My Tasks
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: MyTasksScreen.routeName,
            name: 'my-tasks',
            builder: (context, state) => const MyTasksScreen(),
          ),
        ],
      ),
      // Branch 3: Profile
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: ProfileScreen.routeName,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}