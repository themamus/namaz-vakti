// lib/core/utils/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../constants/app_constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: 'Namaz vakti bildirimleri',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to home screen
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted =
          await androidPlugin.requestNotificationsPermission() ?? false;
      return granted;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> schedulePrayerNotifications({
    required PrayerTimesEntity prayerTimes,
    required Map<String, bool> enabledPrayers,
    required Map<String, bool> vibrationOnly,
    required String azanSound,
  }) async {
    // Cancel all existing notifications first
    await cancelAllNotifications();

    final prayers = prayerTimes.prayerTimesList;
    final prayerKeys = [
      'imsak',
      'sunrise',
      'dhuhr',
      'asr',
      'maghrib',
      'isha',
    ];

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final key = prayerKeys[i];

      if (enabledPrayers[key] != true) continue;

      final prayerDateTime = prayer.dateTime;
      if (prayerDateTime.isBefore(DateTime.now())) continue;

      final scheduledTime = tz.TZDateTime.from(prayerDateTime, tz.local);
      final isVibrationOnly = vibrationOnly[key] == true;

      await _scheduleNotification(
        id: i,
        title: '🕌 ${prayer.name} Vakti',
        body: '${prayer.name} vakti geldi: ${prayer.time}',
        scheduledTime: scheduledTime,
        vibrationOnly: isVibrationOnly,
        soundName: isVibrationOnly ? null : azanSound,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required bool vibrationOnly,
    String? soundName,
  }) async {
    AndroidNotificationDetails androidDetails;

    if (vibrationOnly) {
      androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: soundName != null
            ? RawResourceAndroidNotificationSound(soundName)
            : null,
        enableVibration: true,
      );
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(999, title, body, details);
  }
}
