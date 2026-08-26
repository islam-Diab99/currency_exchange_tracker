import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import 'api_client.dart';
import 'dio_exception_mapper.dart';

/// The Dio-backed [ApiClient]. Together with `DioClient` and `mapDioException`,
/// this is the only place that imports Dio: it does the try/catch and the
/// [DioException] → [AppException] translation once, so data sources stay free
/// of both.
class DioApiClient implements ApiClient {
  DioApiClient(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getJson(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: query,
      );
      final data = res.data;
      if (data == null) throw const ParseException('Empty response');
      return data;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
