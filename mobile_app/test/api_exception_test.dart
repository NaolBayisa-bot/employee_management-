import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management/core/network/api_exception.dart';

void main() {
  group('ApiException.fromDio', () {
    group('network / connectivity errors', () {
      test(
        'connectionError returns "Cannot reach the server. Check your connection."',
        () {
          final exception = DioException(
            requestOptions: RequestOptions(path: '/health'),
            type: DioExceptionType.connectionError,
            error: 'Connection refused',
          );
          final apiException = ApiException.fromDio(exception);
          expect(
            apiException.message,
            'Cannot reach the server. Check your connection.',
          );
          expect(apiException.statusCode, isNull);
        },
      );

      test(
        'connectionTimeout returns "Cannot reach the server. Check your connection."',
        () {
          final exception = DioException.connectionTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: RequestOptions(path: '/health'),
          );
          final apiException = ApiException.fromDio(exception);
          expect(
            apiException.message,
            'Cannot reach the server. Check your connection.',
          );
        },
      );

      test(
        'receiveTimeout returns "Cannot reach the server. Check your connection."',
        () {
          final exception = DioException.receiveTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: RequestOptions(path: '/health'),
          );
          final apiException = ApiException.fromDio(exception);
          expect(
            apiException.message,
            'Cannot reach the server. Check your connection.',
          );
        },
      );

      test(
        'sendTimeout returns "Cannot reach the server. Check your connection."',
        () {
          final exception = DioException.sendTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: RequestOptions(path: '/health'),
          );
          final apiException = ApiException.fromDio(exception);
          expect(
            apiException.message,
            'Cannot reach the server. Check your connection.',
          );
        },
      );
    });

    group('cancel and certificate', () {
      test('cancel returns "Request was cancelled."', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: DioExceptionType.cancel,
        );
        final apiException = ApiException.fromDio(exception);
        expect(apiException.message, 'Request was cancelled.');
      });

      test('badCertificate returns "Certificate error."', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: DioExceptionType.badCertificate,
        );
        final apiException = ApiException.fromDio(exception);
        expect(apiException.message, 'Certificate error.');
      });
    });
    group('badResponse (error responses with a server body)', () {
      test('uses the server message from the response body', () {
        final requestOptions = RequestOptions(path: '/auth/login');
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'Invalid email or password'},
        );
        final exception = DioException.badResponse(
          statusCode: 401,
          requestOptions: requestOptions,
          response: response,
        );
        final apiException = ApiException.fromDio(exception);
        expect(apiException.message, 'Invalid email or password');
        expect(apiException.statusCode, 401);
        expect(apiException.fieldErrors, isNull);
      });

      test('parses validation errors into fieldErrors', () {
        final requestOptions = RequestOptions(path: '/auth/register');
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 400,
          data: {
            'message': 'Validation failed',
            'errors': [
              {
                'field': 'email',
                'message': 'Must be a valid email address',
              },
              {
                'field': 'password',
                'message':
                    'Password must be between 8 and 72 characters',
              },
            ],
          },
        );
        final exception = DioException.badResponse(
          statusCode: 400,
          requestOptions: requestOptions,
          response: response,
        );
        final apiException = ApiException.fromDio(exception);
        expect(apiException.message, 'Validation failed');
        expect(apiException.statusCode, 400);
        expect(apiException.fieldErrors, isNotNull);
        expect(
          apiException.fieldErrors!['email'],
          'Must be a valid email address',
        );
        expect(
          apiException.fieldErrors!['password'],
          'Password must be between 8 and 72 characters',
        );
      });

      test('falls back to "Something went wrong" when body has no message', () {
        final requestOptions = RequestOptions(path: '/tasks');
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 500,
        );
        final exception = DioException.badResponse(
          statusCode: 500,
          requestOptions: requestOptions,
          response: response,
        );
        final apiException = ApiException.fromDio(exception);
        expect(apiException.message, 'Something went wrong');
        expect(apiException.statusCode, 500);
      });
    });

    group('unknown type without response', () {
      test('falls back to "Something went wrong"', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/health'),
        );
        final apiException = ApiException.fromDio(exception);
        expect(apiException.message, 'Something went wrong');
        expect(apiException.statusCode, isNull);
      });
    });
  });

  group('ApiException.combinedMessage', () {
    test('returns just the message when there are no field errors', () {
      final exception = ApiException(message: 'Network error');
      expect(exception.combinedMessage, 'Network error');
    });

    test('appends field errors when present', () {
      final exception = ApiException(
        message: 'Validation failed',
        fieldErrors: {
          'email': 'Must be a valid email address',
          'password': 'Password must be between 8 and 72 characters',
        },
      );
      expect(
        exception.combinedMessage,
        'Validation failed\n'
        'email: Must be a valid email address\n'
        'password: Password must be between 8 and 72 characters',
      );
    });
  });

  group('ApiException.toString', () {
    test('returns the combined message', () {
      final exception = ApiException(message: 'Something went wrong');
      expect(exception.toString(), 'Something went wrong');
    });
  });
}
