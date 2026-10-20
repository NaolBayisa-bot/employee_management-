import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/core/network/api_exception.dart';
import 'package:mobile_app/core/storage/secure_storage.dart';

/// Notified with a fresh timestamp whenever a non-auth 401 is observed.
///
/// The auth provider (Task 4) listens to this and performs the actual sign-out;
/// the interceptor itself never logs the user out — it only *signals*.
final unauthorizedEventProvider = StateProvider<String?>((ref) => null);

/// Shared Dio instance pointing at [AppConfig.apiBaseUrl].
///
/// A single [Provider] keeps one Dio (and one connection pool) for the whole
/// app; the token is read fresh from [TokenStorage] on every request.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      contentType: 'application/json',
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(_AuthInterceptor(ref));
  return dio;
});

/// Adds the bearer token to outgoing requests and converts every network error
/// into an [ApiException], signalling auth expiry via
/// [unauthorizedEventProvider].
class _AuthInterceptor extends Interceptor {
  final Ref ref;

  const _AuthInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await ref.read(tokenStorageProvider).readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = ApiException.fromDio(err);
    if (apiException.statusCode == 401 && !_isAuthRoute(err.requestOptions.path)) {
      // Not an auth route, so an expired/revoked session is the likely cause.
      ref.read(unauthorizedEventProvider.notifier).state =
          DateTime.now().toIso8601String();
    }
    // Build a new DioException carrying the ApiException as its error so that
    // callers can read it back via `e.error`. (The original `err.error` field
    // is final, so it cannot be mutated in place.)
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        stackTrace: err.stackTrace,
        message: apiException.message,
      ),
    );
  }

  bool _isAuthRoute(String path) {
    return path == '/auth/login' || path == '/auth/register';
  }
}
