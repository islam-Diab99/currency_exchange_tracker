import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/core/network/dio_exception_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final options = RequestOptions(path: '/egp.json');

  DioException dioError(DioExceptionType type, {Response<dynamic>? response}) =>
      DioException(requestOptions: options, type: type, response: response);

  Response<dynamic> response(int? status, {dynamic data}) => Response<dynamic>(
    requestOptions: options,
    statusCode: status,
    data: data,
  );

  group('mapDioException — transport types', () {
    test('timeouts map to TimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(mapDioException(dioError(type)), isA<TimeoutException>());
      }
    });

    test('connectionError and unknown map to NetworkException', () {
      expect(
        mapDioException(dioError(DioExceptionType.connectionError)),
        isA<NetworkException>(),
      );
      // `unknown` is usually a SocketException (DNS/host lookup) → offline.
      expect(
        mapDioException(dioError(DioExceptionType.unknown)),
        isA<NetworkException>(),
      );
    });

    test('cancel maps to UnknownException', () {
      expect(
        mapDioException(dioError(DioExceptionType.cancel)),
        isA<UnknownException>(),
      );
    });

    test('badCertificate maps to ServerException', () {
      expect(
        mapDioException(dioError(DioExceptionType.badCertificate)),
        isA<ServerException>(),
      );
    });
  });

  group('mapDioException — HTTP status codes', () {
    AppException mapStatus(int? code, {dynamic data}) => mapDioException(
      dioError(
        DioExceptionType.badResponse,
        response: response(code, data: data),
      ),
    );

    test('translates known client codes', () {
      expect(mapStatus(401), isA<UnauthorizedException>());
      expect(mapStatus(403), isA<ForbiddenException>());
      expect(mapStatus(404), isA<NotFoundException>());
      expect(mapStatus(429), isA<RateLimitException>());
    });

    test('422 surfaces the API-provided message when present', () {
      final result = mapStatus(422, data: {'message': 'name is required'});

      expect(
        result,
        isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'name is required',
        ),
      );
    });

    test('5xx maps to ServerException carrying the status code', () {
      final result = mapStatus(503);

      expect(
        result,
        isA<ServerException>().having((e) => e.statusCode, 'statusCode', 503),
      );
    });

    test('an unmapped code still yields a ServerException', () {
      expect(mapStatus(418), isA<ServerException>());
    });
  });
}
