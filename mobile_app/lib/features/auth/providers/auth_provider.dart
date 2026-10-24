// Authentication state layer.
//
// [authProvider] is an [AsyncNotifier<User?>] where `null` means the user is
// logged out (no valid session). It owns:
//   - token reading from secure storage
//   - JWT expiry checks (jwt_decoder)
//   - /auth/me hydration to read the *live* role/status (the JWT only has {id})
//   - listening to [unauthorizedEventProvider] so a 401 on any business route
//     logs the user out
//
// Error policy (per Task 4 spec):
//   - 401 / expired token / missing token -> log out (state = AsyncData(null))
//   - any OTHER error from the initial fetch -> rethrown so the UI can offer a
//     Retry. We NEVER log the user out because of a transient network error.
//   - login form errors (e.g. wrong password -> 401 "Invalid email or password")
//     are thrown from [login] so the UI decides how to surface them (SnackBar),
//     and do NOT clobber [authProvider] state into an error.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/models/user.dart';
import '../data/auth_repository.dart';

/// Auth state: `AsyncData(null)` = logged out, `AsyncData(user)` = logged in,
/// `AsyncLoading` = initial session restore in progress,
/// `AsyncError` = a non-401 failure on restore (network/500) -> UI shows Retry.
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

/// `true` only when a confirmed user is loaded.
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});

/// The current user's role (ADMIN/MANAGER/EMPLOYEE), or `null` when logged out
/// or while loading.
final currentRoleProvider = Provider<Role?>((ref) {
  return ref.watch(authProvider).valueOrNull?.role;
});

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // React to a 401 from any non-auth route (e.g. a protected API call) by
    // signing the user out. Idempotent: logout() + deleteToken() are safe to
    // repeat, so overlap with an in-flight /auth/me 401 is harmless.
    ref.listen<ApiException?>(unauthorizedEventProvider,
        (previous, next) async {
      if (next != null) {
        await _signOut();
        // Consume the event so we don't loop.
        ref.read(unauthorizedEventProvider.notifier).state = null;
      }
    });

    final token = await ref.read(tokenStorageProvider).readToken();

    // No token -> not logged in.
    if (token == null || token.isEmpty) {
      return null;
    }

    // Expired token -> clear it and treat as logged out.
    if (_isExpired(token)) {
      await ref.read(tokenStorageProvider).deleteToken();
      return null;
    }

    // Token looks valid; hydrate the live user (role/status come from here,
    // NOT from the JWT, which only contains `{ id }`).
    try {
      final user = await ref.read(authRepositoryProvider).fetchMe();
      return user;
    } on ApiException catch (e) {
      // Token rejected/revoked -> sign out cleanly.
      if (e.statusCode == 401) {
        await _signOut();
        return null;
      }
      // 403 (e.g. "Account deactivated") or network/other errors: rethrow so the
      // UI can decide. Network errors must NOT log the user out.
      rethrow;
    }
  }

  /// Persisted login flow. Returns the hydrated [User] on success; throws
  /// [ApiException] (e.g. "Invalid email or password") on failure. State is
  /// set to the user on success; login failures do NOT flip state to AsyncError
  /// (they're surfaced by the UI via the thrown exception).
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = await ref.read(authRepositoryProvider).login(
          email: email,
          password: password,
        );
    // Token is already persisted by the repository; clear any stale
    // unauthorized event and flip state to "logged in".
    ref.read(unauthorizedEventProvider.notifier).state = null;
    state = AsyncData(user);
    return user;
  }

  /// Registration does NOT issue a token (backend returns none and the account
  /// starts PENDING with role=null), so we do not change auth state here.
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
  }) {
    return ref.read(authRepositoryProvider).register(
          name: name,
          email: email,
          password: password,
        );
  }

  /// Drops the stored token and resets state to logged out.
  Future<void> logout() => _signOut();

  /// Re-fetches /auth/me and refreshes the in-memory user (used by a Retry
  /// button after a transient restore error). Returns `null` if the attempt
  /// reveals the session is no longer valid.
  Future<User?> refreshMe() async {
    try {
      final user = await ref.read(authRepositoryProvider).fetchMe();
      state = AsyncData(user);
      return user;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _signOut();
        return null;
      }
      rethrow;
    }
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData<User?>(null);
  }

  /// Treats any failure to decode as "expired" -> forces a clean sign-out.
  static bool _isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }
}
