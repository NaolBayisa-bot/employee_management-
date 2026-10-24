import 'package:dio/dio.dart';

/// Represents an error received from the API or network layer.
/// - [message] is always a human-readable string safe to show to the user.
/// - [statusCode] is the HTTP status code, if available.
/// - [fieldErrors] maps field names to error messages, for validation errors.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  final String message;
  final int? statusCode;
  final Map<String, String>? fieldErrors;

  factory ApiException.fromDio(DioException e) {
    // Network-level errors (no response received)
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Cannot reach the server. Check your connection.',
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      case DioExceptionType.badResponse:
        return ApiException.fromResponse(e);
      case DioExceptionType.badCertificate:
        return ApiException(message: 'Certificate error.');
      default:
        return ApiException.fromResponse(e);
    }
  }

  /// Attempts to extract a message from the error response, falling back
  /// to a generic message if the response is missing or malformed.
  factory ApiException.fromResponse(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      // Standard error shape: { "message": "...", "errors": [...] }
      final message = data['message'] as String? ?? 'Something went wrong';
      final errors = data['errors'];
      Map<String, String>? fieldErrors;

      if (errors is List) {
        fieldErrors = <String, String>{};
        for (final err in errors) {
          if (err is Map<String, dynamic>) {
            final field = err['field'] as String?;
            final msg = err['message'] as String?;
            if (field != null && msg != null) {
              fieldErrors[field] = msg;
            }
          }
        }
        if (fieldErrors.isEmpty) fieldErrors = null;
      }

      return ApiException(
        message: message,
        statusCode: e.response?.statusCode,
        fieldErrors: fieldErrors,
      );
    }

    if (data is String && data.isNotEmpty) {
      return ApiException(
        message: data,
        statusCode: e.response?.statusCode,
      );
    }

    return ApiException(
      message: 'Something went wrong',
      statusCode: e.response?.statusCode,
    );
  }

  /// Convenience: combines all field errors into a single string.
  String get combinedMessage {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return '$message\n${fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
    }
    return message;
  }

  @override
  String toString() => combinedMessage;
}