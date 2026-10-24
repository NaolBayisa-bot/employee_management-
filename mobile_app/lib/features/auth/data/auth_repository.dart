// Auth data-layer repository.
//
// Talks to the backend auth routes documented in
// backend/src/controllers/auth.controller.js and backend/README.md:
//   POST /auth/register  -> { message, user }  (NO token issued)
//   POST /auth/login     -> { token, user }
//   GET  /auth/me        -> { user }            (requires Bearer token)
//   (logout is local-only: we simply delete the saved token)
//
// The JWT payload itself only contains `{ id }` (see backend/src/utils/jwt.js),
// so role/status are always sourced from /auth/me. This repository only deals
// with HTTP + token storage; auth *state* lives in auth_provider.dart.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/models/user.dart';

/// Result of a registration attempt.
@immutable
class RegisterResult {
  const RegisterResult({
    required this.message,
    required this.user,
  });

  final String message;
  final User user;
}

/// Repository for authentication operations against the TaskApp backend.
class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  /// Logs a user in.
  ///
  /// POST /auth/login expects `{ email, password }`.
  /// On success the server returns `{ token, user }`; the token is persisted to
  /// secure storage and the hydrated [User] is returned.
  ///
  /// Network/credentials errors are surfaced as [ApiException] (e.g. the
  /// server message "Invalid email or password").
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from /auth/login',
      );
    }
    final token = data['token'];
    final user = User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    if (token is String && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }
    return user;
  }

  /// Registers a new user.
  ///
  /// POST /auth/register expects `{ name, email, password }`.
  /// IMPORTANT: registration does NOT issue a token — the account starts
  /// PENDING and `role: null`, awaiting admin approval (backend/User.js).
  //  We therefore do NOT save any token here.
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected response from /auth/register',
      );
    }
    final message = data['message'] is String ? data['message'] as String : '';
    final user = User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    return RegisterResult(message: message, user: user);
  }

  /// Fetches the current user via GET /auth/me using the stored Bearer token.
  ///
  /// Used to (re)hydrate the session and to read the live role/status (the JWT
  /// only carries `{ id }`).
  Future<User> fetchMe() async {
    final response = await _apiClient.get('/auth/me');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final userJson = data['user'];
      if (userJson is Map) {
        return User.fromJson(Map<String, dynamic>.from(userJson));
      }
    }
    throw ApiException(message: 'Unexpected response from /auth/me');
  }

  /// Removes the locally stored token (log out).
  Future<void> logout() => _tokenStorage.deleteToken();
}

/// Provider for [AuthRepository]. Wires the shared [ApiClient] and the
/// secure [TokenStorage] together.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(apiClient, tokenStorage);
});
