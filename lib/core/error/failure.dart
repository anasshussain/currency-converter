/// Thrown by the data layer and surfaced to the UI as a readable message.
class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read saved data.']);
}
