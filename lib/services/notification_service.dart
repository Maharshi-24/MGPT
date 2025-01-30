// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 🔥 Ensure notification channel is created
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'instant_notification_channel', // Unique channel ID
      'Instant Notifications',
      description: 'Channel for instant notifications',
      importance: Importance.max,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      print("✅ Notification channel created!");
      List<AndroidNotificationChannel>? channels =
      await androidPlugin.getNotificationChannels();
      print("🔍 Available channels: $channels");
    }

    tz.initializeTimeZones();
  }

  Future<void> scheduleDailyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Reminder',
      'Don\'t forget to use the app today!',
      _nextInstanceOfTime(11,32), // 9:00 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel',
          'Daily Notifications',
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Add this parameter
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> schedulePeriodicNotifications() async {
    // Schedule a notification every 3 hours
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Did you know?',
      'Here\'s a fun fact: Flutter is awesome!',
      _nextInstanceOfTime(DateTime.now().hour + 0, DateTime.now().minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'periodic_notification_channel',
          'Periodic Notifications',
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Add this parameter
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showInstantNotification() async {
    print("🔔 Attempting to show instant notification...");

    await flutterLocalNotificationsPlugin.show(
      2,
      'Test Notification',
      'This is a manual notification.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel', // Ensure this matches the created channel
          'Instant Notifications',
          channelDescription: 'Channel for instant notifications',
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    print("✅ Notification should be displayed!");
  }



  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}