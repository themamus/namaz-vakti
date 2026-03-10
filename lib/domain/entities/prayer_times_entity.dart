// lib/domain/entities/prayer_times_entity.dart

class PrayerTimesEntity {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final HijriDate hijriDate;
  final GregorianDate gregorianDate;
  final String timezone;

  const PrayerTimesEntity({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.hijriDate,
    required this.gregorianDate,
    required this.timezone,
  });

  /// Returns list of prayer times in order
  List<PrayerTime> get prayerTimesList => [
        PrayerTime(name: 'İmsak', nameEn: 'Fajr', time: imsak, index: 0),
        PrayerTime(name: 'Güneş', nameEn: 'Sunrise', time: sunrise, index: 1),
        PrayerTime(name: 'Öğle', nameEn: 'Dhuhr', time: dhuhr, index: 2),
        PrayerTime(name: 'İkindi', nameEn: 'Asr', time: asr, index: 3),
        PrayerTime(name: 'Akşam', nameEn: 'Maghrib', time: maghrib, index: 4),
        PrayerTime(name: 'Yatsı', nameEn: 'Isha', time: isha, index: 5),
      ];
}

class PrayerTime {
  final String name;
  final String nameEn;
  final String time;
  final int index;

  const PrayerTime({
    required this.name,
    required this.nameEn,
    required this.time,
    required this.index,
  });

  /// Parse time string "HH:mm" to DateTime today
  DateTime get dateTime {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get isNext {
    final now = DateTime.now();
    return dateTime.isAfter(now);
  }
}

class HijriDate {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String monthNameEn;

  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.monthNameEn,
  });

  bool get isRamadan => month == 9;

  @override
  String toString() => '$day $monthName $year';
}

class GregorianDate {
  final int day;
  final int month;
  final int year;
  final String weekday;

  const GregorianDate({
    required this.day,
    required this.month,
    required this.year,
    required this.weekday,
  });

  @override
  String toString() => '$day.$month.$year';
}

// lib/domain/entities/location_entity.dart
class LocationEntity {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String countryCode;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.countryCode,
  });

  @override
  String toString() => '$city, $country';
}

// lib/domain/entities/settings_entity.dart
class AppSettings {
  final int calculationMethod;
  final bool notificationsEnabled;
  final bool darkMode;
  final String language;
  final String azanSound;
  final Map<String, bool> prayerNotifications;
  final Map<String, bool> prayerVibration;

  const AppSettings({
    required this.calculationMethod,
    required this.notificationsEnabled,
    required this.darkMode,
    required this.language,
    required this.azanSound,
    required this.prayerNotifications,
    required this.prayerVibration,
  });

  AppSettings copyWith({
    int? calculationMethod,
    bool? notificationsEnabled,
    bool? darkMode,
    String? language,
    String? azanSound,
    Map<String, bool>? prayerNotifications,
    Map<String, bool>? prayerVibration,
  }) {
    return AppSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      azanSound: azanSound ?? this.azanSound,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      prayerVibration: prayerVibration ?? this.prayerVibration,
    );
  }

  factory AppSettings.defaults() {
    return AppSettings(
      calculationMethod: 13, // Diyanet
      notificationsEnabled: true,
      darkMode: false,
      language: 'tr',
      azanSound: 'azan_default',
      prayerNotifications: {
        'imsak': true,
        'sunrise': false,
        'dhuhr': true,
        'asr': true,
        'maghrib': true,
        'isha': true,
      },
      prayerVibration: {
        'imsak': false,
        'sunrise': false,
        'dhuhr': false,
        'asr': false,
        'maghrib': false,
        'isha': false,
      },
    );
  }
}
