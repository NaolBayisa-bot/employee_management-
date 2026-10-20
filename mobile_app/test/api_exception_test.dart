import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/network/api_exception.dart';

void main() {
  group('ApiException.fromDio', () {
    test('connectionError maps to offline message with no statusCode', () {
      final exception = ApiException.fromDio(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/health'),
        ),
      );

      expect(exception.message, 'Cannot reach the server. Check your connection.');
      expect(exception.statusCode, isNull);
      expect(exception.fieldErrors, isNull);
    });

    test('receiveTimeout maps to offline message', () {
      final exception = ApiException.fromDio(
        DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/projects'),
        ),
      );

      expect(exception.message, 'Cannot reach the server. Check your connection.');
    });

    test('badResponse 400 parses server message and field errors', () {
      final exception = ApiException.fromDio(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/projects'),
          response: Response(
            requestOptions: RequestOptions(path: '/projects'),
            statusCode: 400,
            data: <String, dynamic>{
              'message': 'Validation failed',
              'errors': <dynamic>[
                <String, dynamic>{'field': 'name', 'message': 'Name is required'},
                <String, dynamic>{'field': 'title', 'message': 'Title is required'},
              ],
            },
          ),
        ),
      );

      expect(exception.message, 'Validation failed');
      expect(exception.statusCode, 400);
      expect(exception.fieldErrors, isNotNull);
      expect(exception.fieldErrors, hasLength(2));
      expect(exception.fieldErrors![0].field, 'name');
      expect(exception.fieldErrors![0].message, 'Name is required');
    });

    test('badResponse 401 reads auth message', () {
      final exception = ApiException.fromDio(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/projects'),
          response: Response(
            requestOptions: RequestOptions(path: '/projects'),
            statusCode: 401,
            data: <String, dynamic>{'message': 'Authentication required'},
          ),
        ),
      );

      expect(exception.statusCode, 401);
      expect(exception.message, 'Authentication required');
    });

    test('badResponse with non-map body falls back to Something went wrong', () {
      final exception = ApiException.fromDio(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/projects'),
          response: Response(
            requestOptions: RequestOptions(path: '/projects'),
            statusCode: 500,
            data: 'Internal Server Error',
          ),
        ),
      );

      expect(exception.statusCode, 500);
      expect(exception.message, 'Something went wrong');
    });
  });
}
