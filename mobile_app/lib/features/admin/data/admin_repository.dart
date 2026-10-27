// Admin data-layer repository.
//
// Talks to the backend admin routes documented in
// backend/src/controllers/admin.controller.js:
//   GET  /dashboard/stats       -> { totalUsers, pendingUsers, activeProjects, openTasks, doneTasks }
//   GET  /users?status=PENDING  -> { users } (list of pending users)
//   PATCH /users/:id/approve    -> { user } (expects { role: 'MANAGER' | 'EMPLOYEE' })

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/dashboard_stats.dart';
import '../../../shared/models/user.dart';

/// Repository for admin operations against the TaskApp backend.
class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches dashboard statistics.
  ///
  /// GET /dashboard/stats
  /// Returns aggregate counts for the admin dashboard.
  Future<DashboardStats> getStats() async {
    final response = await _apiClient.get('/dashboard/stats');

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Unexpected response from /dashboard/stats');
    }

    final statsJson = data['stats'] ?? data;
    return DashboardStats.fromJson(Map<String, dynamic>.from(statsJson));
  }

  /// Fetches pending users awaiting approval.
  ///
  /// GET /users?status=PENDING
  /// Returns list of users with status PENDING.
  Future<List<User>> getPendingUsers() async {
    final response = await _apiClient.get(
      '/users',
      queryParameters: {'status': 'PENDING'},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Unexpected response from /users');
    }

    final usersRaw = data['users'];
    if (usersRaw is! List) {
      return const <User>[];
    }

    return usersRaw
        .whereType<Map>()
        .map((m) => User.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  /// Approves a pending user with the specified role.
  ///
  /// PATCH /users/:id/approve with body { role: 'MANAGER' | 'EMPLOYEE' }
  /// Returns the updated user (now ACTIVE with assigned role).
  Future<User> approveUser(String id, Role role) async {
    final response = await _apiClient.patch(
      '/users/$id/approve',
      data: {'role': role.toServerValue()},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Unexpected response from PATCH /users/$id/approve');
    }

    final userJson = data['user'];
    if (userJson is! Map) {
      throw ApiException(message: 'Unexpected response format from PATCH /users/$id/approve');
    }

    return User.fromJson(Map<String, dynamic>.from(userJson));
  }
}

/// Provider for [AdminRepository]. Wires the shared [ApiClient] together.
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminRepository(apiClient);
});
