// lib/presentation/providers/settings_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../data/datasources/local/prayer_times_local_datasource.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsLocalDataSource _localDataSource;
  late AppSettings _appSettings;

  SettingsProvider({required SettingsLocalDataSource localDataSource})
      : _localDataSource = localDataSource {
    _loadSettings();
  }

  AppSettings get appSettings => _appSettings;
  bool get isDarkMode => _appSettings.darkMode;
  String get language => _appSettings.language;

  void _loadSettings() {
    _appSettings = AppSettings(
      calculationMethod: _localDataSource.getCalculationMethod(),
      notificationsEnabled: _localDataSource.getNotificationsEnabled(),
      darkMode: _localDataSource.getDarkMode(),
      language: _localDataSource.getLanguage(),
      azanSound: _localDataSource.getAzanSound(),
      prayerNotifications: _localDataSource.getPrayerNotifications(),
      prayerVibration: _localDataSource.getPrayerVibration(),
    );
  }

  Future<void> setCalculationMethod(int method) async {
    await _localDataSource.setCalculationMethod(method);
    _appSettings = _appSettings.copyWith(calculationMethod: method);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _localDataSource.setNotificationsEnabled(value);
    _appSettings = _appSettings.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await _localDataSource.setDarkMode(value);
    _appSettings = _appSettings.copyWith(darkMode: value);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    await _localDataSource.setLanguage(lang);
    _appSettings = _appSettings.copyWith(language: lang);
    notifyListeners();
  }

  Future<void> setAzanSound(String sound) async {
    await _localDataSource.setAzanSound(sound);
    _appSettings = _appSettings.copyWith(azanSound: sound);
    notifyListeners();
  }

  Future<void> setPrayerNotification(String prayer, bool value) async {
    final updated = Map<String, bool>.from(_appSettings.prayerNotifications);
    updated[prayer] = value;
    await _localDataSource.setPrayerNotifications(updated);
    _appSettings = _appSettings.copyWith(prayerNotifications: updated);
    notifyListeners();
  }

  Future<void> setPrayerVibration(String prayer, bool value) async {
    final updated = Map<String, bool>.from(_appSettings.prayerVibration);
    updated[prayer] = value;
    await _localDataSource.setPrayerVibration(updated);
    _appSettings = _appSettings.copyWith(prayerVibration: updated);
    notifyListeners();
  }
}
