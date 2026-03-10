// lib/data/models/prayer_times_model.dart

import '../../domain/entities/prayer_times_entity.dart';

class PrayerTimesModel extends PrayerTimesEntity {
  const PrayerTimesModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
    required super.imsak,
    required super.midnight,
    required super.hijriDate,
    required super.gregorianDate,
    required super.timezone,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;
    final date = data['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    final gregorian = date['gregorian'] as Map<String, dynamic>;
    final meta = data['meta'] as Map<String, dynamic>;

    return PrayerTimesModel(
      fajr: _cleanTime(timings['Fajr'] as String),
      sunrise: _cleanTime(timings['Sunrise'] as String),
      dhuhr: _cleanTime(timings['Dhuhr'] as String),
      asr: _cleanTime(timings['Asr'] as String),
      maghrib: _cleanTime(timings['Maghrib'] as String),
      isha: _cleanTime(timings['Isha'] as String),
      imsak: _cleanTime(timings['Imsak'] as String),
      midnight: _cleanTime(timings['Midnight'] as String),
      hijriDate: HijriDateModel.fromJson(hijri),
      gregorianDate: GregorianDateModel.fromJson(gregorian),
      timezone: meta['timezone'] as String? ?? 'UTC',
    );
  }

  /// Remove timezone offset if present (e.g. "04:30 (EET)" -> "04:30")
  static String _cleanTime(String time) {
    return time.split(' ').first;
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'imsak': imsak,
      'midnight': midnight,
      'hijri': {
        'day': hijriDate.day,
        'month': hijriDate.month,
        'year': hijriDate.year,
        'monthName': hijriDate.monthName,
        'monthNameEn': hijriDate.monthNameEn,
      },
      'gregorian': {
        'day': gregorianDate.day,
        'month': gregorianDate.month,
        'year': gregorianDate.year,
        'weekday': gregorianDate.weekday,
      },
      'timezone': timezone,
    };
  }

  factory PrayerTimesModel.fromCache(Map<String, dynamic> json) {
    return PrayerTimesModel(
      fajr: json['fajr'] as String,
      sunrise: json['sunrise'] as String,
      dhuhr: json['dhuhr'] as String,
      asr: json['asr'] as String,
      maghrib: json['maghrib'] as String,
      isha: json['isha'] as String,
      imsak: json['imsak'] as String,
      midnight: json['midnight'] as String,
      hijriDate: HijriDateModel.fromCache(
          json['hijri'] as Map<String, dynamic>),
      gregorianDate: GregorianDateModel.fromCache(
          json['gregorian'] as Map<String, dynamic>),
      timezone: json['timezone'] as String,
    );
  }
}

class HijriDateModel extends HijriDate {
  const HijriDateModel({
    required super.day,
    required super.month,
    required super.year,
    required super.monthName,
    required super.monthNameEn,
  });

  factory HijriDateModel.fromJson(Map<String, dynamic> json) {
    final monthData = json['month'] as Map<String, dynamic>;
    return HijriDateModel(
      day: int.parse(json['day'] as String),
      month: int.parse(monthData['number'].toString()),
      year: int.parse(json['year'] as String),
      monthName: (json['month'] as Map<String, dynamic>)['ar'] as String? ??
          monthData['en'] as String,
      monthNameEn: monthData['en'] as String,
    );
  }

  factory HijriDateModel.fromCache(Map<String, dynamic> json) {
    return HijriDateModel(
      day: json['day'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
      monthName: json['monthName'] as String,
      monthNameEn: json['monthNameEn'] as String,
    );
  }
}

class GregorianDateModel extends GregorianDate {
  const GregorianDateModel({
    required super.day,
    required super.month,
    required super.year,
    required super.weekday,
  });

  factory GregorianDateModel.fromJson(Map<String, dynamic> json) {
    return GregorianDateModel(
      day: int.parse(json['day'] as String),
      month: int.parse(
          (json['month'] as Map<String, dynamic>)['number'].toString()),
      year: int.parse(json['year'] as String),
      weekday:
          (json['weekday'] as Map<String, dynamic>)['en'] as String? ?? '',
    );
  }

  factory GregorianDateModel.fromCache(Map<String, dynamic> json) {
    return GregorianDateModel(
      day: json['day'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
      weekday: json['weekday'] as String,
    );
  }
}
