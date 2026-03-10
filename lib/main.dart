// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'core/theme/app_theme.dart';
import 'core/utils/location_service.dart';
import 'core/utils/notification_service.dart';
import 'data/datasources/local/prayer_times_local_datasource.dart';
import 'data/datasources/remote/prayer_times_remote_datasource.dart';
import 'data/repositories/prayer_times_repository_impl.dart';
import 'presentation/providers/prayer_times_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    NamazVaktiApp(
      sharedPreferences: sharedPreferences,
      notificationService: notificationService,
    ),
  );
}

class NamazVaktiApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final NotificationService notificationService;

  const NamazVaktiApp({
    super.key,
    required this.sharedPreferences,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    // Dependency injection via Provider
    return MultiProvider(
      providers: [
        // Settings provider
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(
            localDataSource: SettingsLocalDataSource(
              sharedPreferences: sharedPreferences,
            ),
          ),
        ),

        // Prayer times provider
        ChangeNotifierProvider<PrayerTimesProvider>(
          create: (_) {
            final localDs = PrayerTimesLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );
            final remoteDs = PrayerTimesRemoteDataSourceImpl(
              client: http.Client(),
            );
            final repository = PrayerTimesRepositoryImpl(
              remoteDataSource: remoteDs,
              localDataSource: localDs,
              connectivity: Connectivity(),
            );

            return PrayerTimesProvider(
              repository: repository,
              locationService: LocationService(),
              notificationService: notificationService,
            );
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Namaz Vakti',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
