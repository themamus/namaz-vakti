// lib/data/datasources/remote/prayer_times_remote_datasource.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/prayer_times_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';

abstract class PrayerTimesRemoteDataSource {
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    required int method,
    String? date,
  });

  Future<PrayerTimesModel> getPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
    String? date,
  });

  Future<List<PrayerTimesModel>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int month,
    required int year,
  });
}

class PrayerTimesRemoteDataSourceImpl implements PrayerTimesRemoteDataSource {
  final http.Client client;

  PrayerTimesRemoteDataSourceImpl({required this.client});

  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    required int method,
    String? date,
  }) async {
    final targetDate = date ?? _todayString();
    final url = Uri.parse(
      '${AppConstants.aladhanBaseUrl}/timings/$targetDate'
      '?latitude=$latitude&longitude=$longitude'
      '&method=$method'
      '&school=1', // Hanafi school for Asr
    );

    return _fetchPrayerTimes(url);
  }

  @override
  Future<PrayerTimesModel> getPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
    String? date,
  }) async {
    final targetDate = date ?? _todayString();
    final url = Uri.parse(
      '${AppConstants.aladhanBaseUrl}/timingsByCity/$targetDate'
      '?city=${Uri.encodeComponent(city)}'
      '&country=${Uri.encodeComponent(country)}'
      '&method=$method'
      '&school=1',
    );

    return _fetchPrayerTimes(url);
  }

  @override
  Future<List<PrayerTimesModel>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int month,
    required int year,
  }) async {
    final url = Uri.parse(
      '${AppConstants.aladhanBaseUrl}/calendar/$year/$month'
      '?latitude=$latitude&longitude=$longitude'
      '&method=$method'
      '&school=1',
    );

    try {
      final response = await client
          .get(url)
          .timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (jsonData['code'] == 200) {
          final dataList = jsonData['data'] as List;
          return dataList.map((day) {
            return PrayerTimesModel.fromJson({'data': day});
          }).toList();
        } else {
          throw ServerException('API hatası: ${jsonData['status']}');
        }
      } else {
        throw ServerException(
          'HTTP hatası: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Bağlantı zaman aşımına uğradı');
    }
  }

  Future<PrayerTimesModel> _fetchPrayerTimes(Uri url) async {
    try {
      final response = await client
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (jsonData['code'] == 200) {
          return PrayerTimesModel.fromJson(jsonData);
        } else {
          throw ServerException('API hatası: ${jsonData['status']}');
        }
      } else if (response.statusCode == 404) {
        throw ServerException('Şehir bulunamadı', 404);
      } else {
        throw ServerException(
          'Sunucu hatası: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Bağlantı zaman aşımına uğradı');
    } on FormatException {
      throw ServerException('Geçersiz API yanıtı');
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }
}
