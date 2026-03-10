// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Namaz Vakti';
  static const String appVersion = '1.0.0';

  // API
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const int apiTimeoutSeconds = 30;

  // Cache
  static const String prayerTimesBoxName = 'prayer_times_box';
  static const String settingsBoxName = 'settings_box';
  static const String locationBoxName = 'location_box';
  static const int cacheExpiryHours = 24;

  // Prayer Names (Turkish)
  static const List<String> prayerNamesTr = [
    'İmsak',
    'Güneş',
    'Öğle',
    'İkindi',
    'Akşam',
    'Yatsı',
  ];

  // Prayer Names (English)
  static const List<String> prayerNamesEn = [
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  // Calculation Methods
  static const Map<int, String> calculationMethods = {
    1: 'Muslim World League',
    2: 'Islamic Society of North America',
    3: 'Egyptian General Authority',
    4: 'Umm Al-Qura University',
    5: 'University of Islamic Sciences, Karachi',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Majlis Ugama Islam Singapura',
    12: 'Union Organization Islamic de France',
    13: 'Diyanet İşleri Başkanlığı',
    14: 'Spiritual Administration of Muslims of Russia',
  };

  // Notification IDs
  static const int fajrNotificationId = 0;
  static const int sunriseNotificationId = 1;
  static const int dhuhrNotificationId = 2;
  static const int asrNotificationId = 3;
  static const int maghribNotificationId = 4;
  static const int ishaNotificationId = 5;

  // Notification Channel
  static const String notificationChannelId = 'namaz_vakti_channel';
  static const String notificationChannelName = 'Namaz Vakti Bildirimleri';

  // Qibla - Mecca Coordinates
  static const double meccaLatitude = 21.3891;
  static const double meccaLongitude = 39.8579;

  // Supported Languages
  static const List<String> supportedLanguages = ['tr', 'en', 'ar'];

  // Default Settings
  static const int defaultCalculationMethod = 13; // Diyanet
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultDarkMode = false;
  static const String defaultAzanSound = 'azan_default';
}
