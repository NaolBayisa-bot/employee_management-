import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

/// A thin wrapper around [Dio] that provides typed access to the API client
/// and converts all DioExceptions into [ApiException]s.
class ApiClient {
  ApiClient(this.dio);

  final Dio dio;

  /// Sends a GET request to [path] with optional [queryParameters].
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.fetch<T>(
        _buildOptions('GET', path, data, queryParameters, options),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.fetch<T>(
        _buildOptions('POST', path, data, queryParameters, options),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.fetch<T>(
        _buildOptions('PATCH', path, data, queryParameters, options),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.fetch<T>(
        _buildOptions('DELETE', path, data, queryParameters, options),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  RequestOptions _buildOptions<T>(
    String method,
    String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  ) {
    final opts = (options ?? Options()).copyWith(method: method);
    return opts.compose(
      dio.options,
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }
}

/// A [StateProvider] that holds an [ApiException] when a 401 Unauthorized
/// is received on a non-auth route (e.g. token expired or revoked).
/// The auth provider listens to this in Task 4.
final unauthorizedEventProvider =
    StateProvider<ApiException?>((ref) => null);

/// Provider for the fully-configured [Dio] instance.
///
/// Configures:
/// - [AppConfig.apiBaseUrl] as the base URL
/// - 15-second connect and receive timeouts
/// - JSON content/response type headers
/// - An interceptor that attaches the JWT token from [TokenStorage]
///   to every request and notifies [unauthorizedEventProvider] on 401s
///   for non-auth routes.
final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attach auth token to every request
        final token = await tokenStorage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // For non-auth requests that return 401, notify the auth system
        final path = e.requestOptions.path;
        if (e.response?.statusCode == 401 &&
            !path.contains('/auth/login') &&
            !path.contains('/auth/register')) {
          ref.read(unauthorizedEventProvider.notifier).state =
              ApiException.fromDio(e);
        }
        return handler.reject(e);
      },
    ),
  );

  return dio;
});

/// Provider for [ApiClient]. Depends on [dioProvider] so the configured
/// [Dio] instance is created once and shared, and every [DioException]
/// is converted into an [ApiException].
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
