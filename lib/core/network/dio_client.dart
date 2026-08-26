import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:requests_inspector/requests_inspector.dart';

class DioClient {
  const DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );

    // Feeds every request/response into the in-app inspector (debug only).
    if (!kReleaseMode) {
      dio.interceptors.add(RequestsInspectorInterceptor());
    }

    return dio;
  }
}
