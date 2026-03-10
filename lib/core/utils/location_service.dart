// lib/core/utils/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../errors/failures.dart';

class LocationService {
  Future<LocationEntity> getCurrentLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Konum servisi kapalı. Lütfen GPS\'i açın.');
    }

    // Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionException(
            'Konum izni reddedildi. Lütfen ayarlardan izin verin.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionException(
          'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      // Reverse geocoding
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String city = 'Bilinmiyor';
      String country = 'TR';
      String countryCode = 'TR';

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        city = placemark.administrativeArea ??
            placemark.subAdministrativeArea ??
            placemark.locality ??
            'Bilinmiyor';
        country = placemark.country ?? 'Türkiye';
        countryCode = placemark.isoCountryCode ?? 'TR';
      }

      return LocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        country: country,
        countryCode: countryCode,
      );
    } on PermissionException {
      rethrow;
    } catch (e) {
      throw LocationException('Konum alınamadı: $e');
    }
  }

  Future<LocationEntity?> searchCity(String cityName) async {
    try {
      final locations = await locationFromAddress(cityName);
      if (locations.isEmpty) return null;

      final location = locations.first;
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      String city = cityName;
      String country = 'TR';
      String countryCode = 'TR';

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        city = placemark.administrativeArea ??
            placemark.locality ??
            cityName;
        country = placemark.country ?? 'Türkiye';
        countryCode = placemark.isoCountryCode ?? 'TR';
      }

      return LocationEntity(
        latitude: location.latitude,
        longitude: location.longitude,
        city: city,
        country: country,
        countryCode: countryCode,
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 1000, // Only update when moved 1km
      ),
    );
  }
}
