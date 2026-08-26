import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Abstraction over device connectivity so the rest of the app never depends
/// on a specific plugin directly (keeps it mockable and swappable).
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}


class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connection);

  final InternetConnection _connection;

  @override
  Future<bool> get isConnected => _connection.hasInternetAccess;

  @override
  Stream<bool> get onConnectivityChanged => _connection.onStatusChange
      .map((status) => status == InternetStatus.connected);
}
