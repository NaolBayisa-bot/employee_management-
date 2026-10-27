// Admin providers layer.
//
// Provides [FutureProvider] for dashboard stats and pending users,
// with refresh capability and an approve action that tracks per-user loading.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/dashboard_stats.dart';
import '../../../shared/models/user.dart';
import '../data/admin_repository.dart';

/// Provider for dashboard statistics.
/// Uses autoDispose to release when not visible.
final statsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getStats();
});

/// Provider for pending users list.
/// Uses autoDispose to release when not visible.
final pendingUsersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getPendingUsers();
});

/// Notifier for approving a pending user.
/// Tracks loading state per user ID and invalidates related providers on success.
class AdminApprovalNotifier extends AutoDisposeNotifier<Map<String, AsyncValue<void>>> {
  @override
  Map<String, AsyncValue<void>> build() => {};

  /// Approves a user with the given role.
  /// Returns the approved user on success, throws on failure.
  Future<User> approveUser(String userId, Role role, String userName) async {
    // Set loading state for this specific user
    state = {...state, userId: const AsyncLoading()};

    try {
      final repository = ref.read(adminRepositoryProvider);
      final approvedUser = await repository.approveUser(userId, role);

      // Clear loading state for this user
      final newState = Map<String, AsyncValue<void>>.from(state);
      newState.remove(userId);
      state = newState;

      // Invalidate providers to refresh UI
      ref.invalidate(statsProvider);
      ref.invalidate(pendingUsersProvider);

      return approvedUser;
    } catch (e, stack) {
      // Set error state for this user
      state = {...state, userId: AsyncError(e, stack)};
      rethrow;
    }
  }

  /// Gets the loading/error state for a specific user.
  AsyncValue<void>? getState(String userId) => state[userId];
}

/// Provider for the admin approval notifier.
final adminApprovalProvider = AutoDisposeNotifierProvider<AdminApprovalNotifier, Map<String, AsyncValue<void>>>(
  AdminApprovalNotifier.new,
);
