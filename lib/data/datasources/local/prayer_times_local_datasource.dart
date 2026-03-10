// lib/data/datasources/local/prayer_times_local_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/prayer_times_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';

abstract class PrayerTimesLocalDataSource {
  Future<PrayerTimesModel?> getCachedPrayerTimes(String cacheKey);
  Future<void> cachePrayerTimes(String cacheKey, PrayerTimesModel model);
  Future<void> clearCache();
  bool isCacheValid(String cacheKey);
}

class PrayerTimesLocalDataSourceImpl implements PrayerTimesLocalDataSource {
  final SharedPreferences sharedPreferences;

  PrayerTimesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<PrayerTimesModel?> getCachedPrayerTimes(String cacheKey) async {
    try {
      final jsonString = sharedPreferences.getString(cacheKey);
      if (jsonString == null) return null;

      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return PrayerTimesModel.fromCache(jsonData);
    } catch (e) {
      throw CacheException('Önbellek okuma hatası: $e');
    }
  }

  @override
  Future<void> cachePrayerTimes(
      String cacheKey, PrayerTimesModel model) async {
    try {
      final cacheData = {
        ...model.toJson(),
        'cachedAt': DateTime.now().toIso8601String(),
      };
      await sharedPreferences.setString(
        cacheKey,
        json.encode(cacheData),
      );
    } catch (e) {
      throw CacheException('Önbellek yazma hatası: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key.startsWith('prayer_')) {
        await sharedPreferences.remove(key);
      }
    }
  }

  @override
  bool isCacheValid(String cacheKey) {
    try {
      final jsonString = sharedPreferences.getString(cacheKey);
      if (jsonString == null) return false;

      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(jsonData['cachedAt'] as String);
      final expiryTime = cachedAt.add(
        Duration(hours: AppConstants.cacheExpiryHours),
      );

      return DateTime.now().isBefore(expiryTime);
    } catch (_) {
      return false;
    }
  }

  String buildCacheKey({
    required double latitude,
    required double longitude,
    required String date,
    required int method,
  }) {
    return 'prayer_${latitude.toStringAsFixed(2)}_'
        '${longitude.toStringAsFixed(2)}_${date}_$method';
  }
}

// lib/data/datasources/local/settings_local_datasource.dart
class SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSource({required this.sharedPreferences});

  static const String _calcMethodKey = 'calc_method';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';
  static const String _azanSoundKey = 'azan_sound';
  static const String _prayerNotifKey = 'prayer_notifications';
  static const String _prayerVibKey = 'prayer_vibration';
  static const String _lastLatKey = 'last_latitude';
  static const String _lastLngKey = 'last_longitude';
  static const String _lastCityKey = 'last_city';
  static const String _lastCountryKey = 'last_country';

  int getCalculationMethod() =>
      sharedPreferences.getInt(_calcMethodKey) ?? 13;

  Future<void> setCalculationMethod(int method) =>
      sharedPreferences.setInt(_calcMethodKey, method);

  bool getNotificationsEnabled() =>
      sharedPreferences.getBool(_notificationsKey) ?? true;

  Future<void> setNotificationsEnabled(bool value) =>
      sharedPreferences.setBool(_notificationsKey, value);

  bool getDarkMode() =>
      sharedPreferences.getBool(_darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) =>
      sharedPreferences.setBool(_darkModeKey, value);

  String getLanguage() =>
      sharedPreferences.getString(_languageKey) ?? 'tr';

  Future<void> setLanguage(String lang) =>
      sharedPreferences.setString(_languageKey, lang);

  String getAzanSound() =>
      sharedPreferences.getString(_azanSoundKey) ?? 'azan_default';

  Future<void> setAzanSound(String sound) =>
      sharedPreferences.setString(_azanSoundKey, sound);

  Map<String, bool> getPrayerNotifications() {
    final jsonStr = sharedPreferences.getString(_prayerNotifKey);
    if (jsonStr == null) {
      return {
        'imsak': true,
        'sunrise': false,
        'dhuhr': true,
        'asr': true,
        'maghrib': true,
        'isha': true,
      };
    }
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as bool));
  }

  Future<void> setPrayerNotifications(Map<String, bool> notifications) =>
      sharedPreferences.setString(_prayerNotifKey, json.encode(notifications));

  Map<String, bool> getPrayerVibration() {
    final jsonStr = sharedPreferences.getString(_prayerVibKey);
    if (jsonStr == null) {
      return {
        'imsak': false,
        'sunrise': false,
        'dhuhr': false,
        'asr': false,
        'maghrib': false,
        'isha': false,
      };
    }
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as bool));
  }

  Future<void> setPrayerVibration(Map<String, bool> vibration) =>
      sharedPreferences.setString(_prayerVibKey, json.encode(vibration));

  // Location cache
  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    required String city,
    required String country,
  }) async {
    await sharedPreferences.setDouble(_lastLatKey, latitude);
    await sharedPreferences.setDouble(_lastLngKey, longitude);
    await sharedPreferences.setString(_lastCityKey, city);
    await sharedPreferences.setString(_lastCountryKey, country);
  }

  Map<String, dynamic>? getLastLocation() {
    final lat = sharedPreferences.getDouble(_lastLatKey);
    final lng = sharedPreferences.getDouble(_lastLngKey);
    final city = sharedPreferences.getString(_lastCityKey);
    final country = sharedPreferences.getString(_lastCountryKey);

    if (lat == null || lng == null || city == null) return null;

    return {
      'latitude': lat,
      'longitude': lng,
      'city': city,
      'country': country ?? '',
    };
  }
}
