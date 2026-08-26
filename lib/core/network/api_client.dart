abstract interface class ApiClient {
  /// Performs a GET and returns the decoded JSON object.
  ///
  /// Throws an [AppException] (from `exceptions.dart`) on any failure —
  /// transport, HTTP status, or an empty/unshaped body. Never throws a Dio type.
  Future<Map<String, dynamic>> getJson(
    String url, {
    Map<String, dynamic>? query,
  });
}
