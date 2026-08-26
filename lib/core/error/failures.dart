import 'package:equatable/equatable.dart';


sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// The API failed or returned an error response.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}

/// The device has no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// No cached data was available to fall back on.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No saved data available yet.']);
}

/// The response could not be parsed into the expected shape.
class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Received unexpected data.']);
}
