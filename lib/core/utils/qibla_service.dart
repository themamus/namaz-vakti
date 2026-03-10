// lib/core/utils/qibla_service.dart

import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import '../constants/app_constants.dart';

class QiblaService {
  /// Calculate the bearing from a location to Mecca
  static double calculateQiblaDirection({
    required double latitude,
    required double longitude,
  }) {
    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(AppConstants.meccaLatitude);
    final dLong = _toRadians(AppConstants.meccaLongitude - longitude);

    final y = math.sin(dLong) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLong);

    final bearing = math.atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// Calculate distance to Mecca in kilometers
  static double calculateDistanceToMecca({
    required double latitude,
    required double longitude,
  }) {
    const earthRadius = 6371.0;

    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(AppConstants.meccaLatitude);
    final dLat = _toRadians(AppConstants.meccaLatitude - latitude);
    final dLon = _toRadians(AppConstants.meccaLongitude - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static Stream<CompassEvent?> getCompassStream() {
    return FlutterCompass.events ?? const Stream.empty();
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;
}
