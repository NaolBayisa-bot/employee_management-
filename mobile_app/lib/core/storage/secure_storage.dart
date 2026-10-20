import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores only the auth *token* (never a password) in the OS keychain/
/// keystore via [FlutterSecureStorage].
class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage(FlutterSecureStorage storage) : _storage = storage;

  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() {
    return _storage.delete(key: _tokenKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(FlutterSecureStorage());
});
