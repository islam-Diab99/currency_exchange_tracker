import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:requests_inspector/requests_inspector.dart';

class DioClient {
  const DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        // Kept short so an unreachable host fails fast (offline → cache
        // fallback) instead of leaving the refresh spinner hanging.
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 8),
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
