import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secure storage wrapper for JWT tokens.
/// Uses the OS keychain on iOS and Android Keystore on Android.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}

/// Provider for [TokenStorage] using default [FlutterSecureStorage].
/// On Android, this uses the default encrypted SharedPreferences (AES-GCM
/// with RSA OAEP key wrapping), so no explicit options are needed.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = const FlutterSecureStorage();
  return TokenStorage(storage);
});