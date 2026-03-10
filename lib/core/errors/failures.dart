// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'İnternet bağlantısı yok']) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Sunucu hatası oluştu']) : super(message);
}

class LocationFailure extends Failure {
  const LocationFailure([String message = 'Konum tespit edilemedi']) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'İzin verilmedi']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Önbellek hatası']) : super(message);
}

class SensorFailure extends Failure {
  const SensorFailure([String message = 'Sensör hatası']) : super(message);
}

// lib/core/errors/exceptions.dart
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'İnternet bağlantısı yok']);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException([this.message = 'Sunucu hatası', this.statusCode]);
  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class LocationException implements Exception {
  final String message;
  LocationException([this.message = 'Konum alınamadı']);
  @override
  String toString() => message;
}

class PermissionException implements Exception {
  final String message;
  PermissionException([this.message = 'İzin verilmedi']);
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Önbellek hatası']);
  @override
  String toString() => message;
}
