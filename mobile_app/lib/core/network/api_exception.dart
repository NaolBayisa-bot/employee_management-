import 'package:dio/dio.dart';

/// User-facing error produced by the backend or by the network layer.
///
/// The mobile UI only ever surfaces [message] to the user; per the product
/// rule this string is safe to display and never contains a secret.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Per-field validation messages, populated only for 400 responses that
  /// carry an `errors` list.
  final List<FieldError>? fieldErrors;

  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  /// Builds an [ApiException] from a [DioException].
  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        // No server contact was possible.
        return ApiException(message: 'Cannot reach the server. Check your connection.');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final dynamic rawMessage = data['message'];
          final String message = (rawMessage is String && rawMessage.trim().isNotEmpty)
              ? rawMessage
              : 'Something went wrong';
          return ApiException(
            message: message,
            statusCode: e.response?.statusCode,
            fieldErrors: _parseFieldErrors(data['errors']),
          );
        }
        return ApiException(
          message: 'Something went wrong',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        return ApiException(message: 'Something went wrong');
    }
  }

  static List<FieldError>? _parseFieldErrors(dynamic errors) {
    if (errors is! List) {
      return null;
    }
    final parsed = errors
        .whereType<Map<String, dynamic>>()
        .map((dynamic raw) => FieldError.fromJson(raw as Map<String, dynamic>))
        .toList();
    return parsed.isEmpty ? null : parsed;
  }

  @override
  String toString() => message;
}

/// Single field-level validation error, e.g. `{"field":"name","message":"..."}`.
class FieldError {
  final String field;
  final String message;

  FieldError({
    required this.field,
    required this.message,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
