// lib/data/repositories/prayer_times_repository_impl.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/local/prayer_times_local_datasource.dart';
import '../datasources/remote/prayer_times_remote_datasource.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../core/errors/failures.dart';

abstract class PrayerTimesRepository {
  Future<PrayerTimesEntity> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
  });

  Future<PrayerTimesEntity> getPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
  });

  Future<List<PrayerTimesEntity>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
  });
}

class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final PrayerTimesRemoteDataSource remoteDataSource;
  final PrayerTimesLocalDataSourceImpl localDataSource;
  final Connectivity connectivity;

  PrayerTimesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<PrayerTimesEntity> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
  }) async {
    final today = _todayString();
    final cacheKey = localDataSource.buildCacheKey(
      latitude: latitude,
      longitude: longitude,
      date: today,
      method: method,
    );

    // Check cache first
    if (localDataSource.isCacheValid(cacheKey)) {
      final cached = await localDataSource.getCachedPrayerTimes(cacheKey);
      if (cached != null) return cached;
    }

    // Check connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Try to return stale cache if no internet
      final staleCache = await localDataSource.getCachedPrayerTimes(cacheKey);
      if (staleCache != null) return staleCache;
      throw NetworkFailure();
    }

    // Fetch from API
    try {
      final model = await remoteDataSource.getPrayerTimesByCoordinates(
        latitude: latitude,
        longitude: longitude,
        method: method,
      );

      // Cache the result
      await localDataSource.cachePrayerTimes(cacheKey, model);
      return model;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<PrayerTimesEntity> getPrayerTimesByCity({
    required String city,
    required String country,
    required int method,
  }) async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw const NetworkFailure();
    }

    try {
      return await remoteDataSource.getPrayerTimesByCity(
        city: city,
        country: country,
        method: method,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<PrayerTimesEntity>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
  }) async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw const NetworkFailure();
    }

    final now = DateTime.now();

    try {
      return await remoteDataSource.getMonthlyPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        method: method,
        month: now.month,
        year: now.year,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }
}
