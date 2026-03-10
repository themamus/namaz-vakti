// lib/presentation/providers/prayer_times_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../data/repositories/prayer_times_repository_impl.dart';
import '../../core/utils/location_service.dart';
import '../../core/utils/notification_service.dart';
import '../../core/errors/failures.dart';
import 'settings_provider.dart';

enum PrayerTimesStatus { initial, loading, loaded, error }

class PrayerTimesProvider extends ChangeNotifier {
  final PrayerTimesRepository _repository;
  final LocationService _locationService;
  final NotificationService _notificationService;

  PrayerTimesStatus _status = PrayerTimesStatus.initial;
  PrayerTimesEntity? _prayerTimes;
  LocationEntity? _location;
  String? _errorMessage;
  Timer? _countdownTimer;
  Duration _timeToNextPrayer = Duration.zero;
  PrayerTime? _nextPrayer;
  PrayerTime? _currentPrayer;

  PrayerTimesProvider({
    required PrayerTimesRepository repository,
    required LocationService locationService,
    required NotificationService notificationService,
  })  : _repository = repository,
        _locationService = locationService,
        _notificationService = notificationService;

  // Getters
  PrayerTimesStatus get status => _status;
  PrayerTimesEntity? get prayerTimes => _prayerTimes;
  LocationEntity? get location => _location;
  String? get errorMessage => _errorMessage;
  Duration get timeToNextPrayer => _timeToNextPrayer;
  PrayerTime? get nextPrayer => _nextPrayer;
  PrayerTime? get currentPrayer => _currentPrayer;
  bool get isLoading => _status == PrayerTimesStatus.loading;
  bool get isRamadan => _prayerTimes?.hijriDate.isRamadan ?? false;

  Future<void> loadPrayerTimes({int? method}) async {
    _status = PrayerTimesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get location
      _location = await _locationService.getCurrentLocation();

      // Fetch prayer times
      _prayerTimes = await _repository.getPrayerTimes(
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        method: method ?? 13,
      );

      _status = PrayerTimesStatus.loaded;
      _startCountdown();
      _updateCurrentAndNextPrayer();
    } on LocationFailure catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = e.message;
    } on PermissionFailure catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = e.message;
    } on NetworkFailure catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = e.message;
    } on ServerFailure catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = 'Bilinmeyen bir hata oluştu: $e';
    }

    notifyListeners();
  }

  Future<void> loadPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
  }) async {
    _status = PrayerTimesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _prayerTimes = await _repository.getPrayerTimesByCity(
        city: city,
        country: country,
        method: method,
      );

      // Get location entity from city search
      final searchResult = await _locationService.searchCity('$city $country');
      if (searchResult != null) {
        _location = searchResult;
      } else {
        _location = LocationEntity(
          latitude: 0,
          longitude: 0,
          city: city,
          country: country,
          countryCode: '',
        );
      }

      _status = PrayerTimesStatus.loaded;
      _startCountdown();
      _updateCurrentAndNextPrayer();
    } on NetworkFailure catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = e.message;
    } on ServerFailure catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = PrayerTimesStatus.error;
      _errorMessage = 'Şehir bulunamadı: $e';
    }

    notifyListeners();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    _updateCurrentAndNextPrayer();
    notifyListeners();
  }

  void _updateCurrentAndNextPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final prayers = _prayerTimes!.prayerTimesList;

    PrayerTime? next;
    PrayerTime? current;

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final prayerTime = prayer.dateTime;

      if (prayerTime.isAfter(now)) {
        next = prayer;
        current = i > 0 ? prayers[i - 1] : prayers.last;
        break;
      }
    }

    // If all prayers have passed, next prayer is tomorrow's Fajr
    if (next == null && prayers.isNotEmpty) {
      next = prayers.first;
      current = prayers.last;
    }

    _nextPrayer = next;
    _currentPrayer = current;

    if (next != null) {
      final nextTime = next.dateTime;
      if (nextTime.isBefore(now)) {
        // Tomorrow's prayer
        final tomorrow = nextTime.add(const Duration(days: 1));
        _timeToNextPrayer = tomorrow.difference(now);
      } else {
        _timeToNextPrayer = nextTime.difference(now);
      }
    }
  }

  Future<void> scheduleNotifications(SettingsProvider settings) async {
    if (_prayerTimes == null) return;

    await _notificationService.schedulePrayerNotifications(
      prayerTimes: _prayerTimes!,
      enabledPrayers: settings.appSettings.prayerNotifications,
      vibrationOnly: settings.appSettings.prayerVibration,
      azanSound: settings.appSettings.azanSound,
    );
  }

  String formatCountdown() {
    final hours = _timeToNextPrayer.inHours;
    final minutes = _timeToNextPrayer.inMinutes % 60;
    final seconds = _timeToNextPrayer.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
