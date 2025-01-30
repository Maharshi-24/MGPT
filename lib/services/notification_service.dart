import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

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

    // 🔥 Request notification permissions (Android 13+)
    await _requestPermissions();

    // Ensure timezone is initialized
    tz.initializeTimeZones();

    // 🔥 Ensure the notification channel exists
    await _createNotificationChannels();
  }

  /// Request notification permissions for Android 13+ and iOS
  Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      print("⚠️ Notifications Denied. Opening App Settings...");
      openAppSettings(); // Opens system settings
    } else {
      print("✅ Notifications Allowed!");
    }
  }

  /// Create necessary notification channels for Android 8.0+
  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const AndroidNotificationChannel instantChannel = AndroidNotificationChannel(
        'instant_notification_channel',
        'Instant Notifications',
        description: 'Channel for instant notifications',
        importance: Importance.max,
      );

      const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
        'daily_notification_channel',
        'Daily Notifications',
        description: 'Channel for daily reminders',
        importance: Importance.max,
      );

      const AndroidNotificationChannel periodicChannel = AndroidNotificationChannel(
        'periodic_notification_channel',
        'Periodic Notifications',
        description: 'Channel for periodic notifications',
        importance: Importance.max,
      );

      await androidPlugin.createNotificationChannel(instantChannel);
      await androidPlugin.createNotificationChannel(dailyChannel);
      await androidPlugin.createNotificationChannel(periodicChannel);

      print("✅ Notification channels created!");
    }
  }

  /// Show an instant notification (manual trigger)
  Future<void> showInstantNotification() async {
    print("🔔 Attempting to show instant notification...");

    await flutterLocalNotificationsPlugin.show(
      2,
      'You know...',
      'Eggs are the best🥚😋',
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

  /// Schedule a daily notification at a fixed time
  Future<void> scheduleDailyNotification() async {
    print("🕒 Scheduling daily notification...");

    tz.TZDateTime scheduledTime = _nextInstanceOfTime(11, 55);
    print("📅 Scheduled time: $scheduledTime");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Reminder',
      'Don\'t forget to use the app today!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel',
          'Daily Notifications',
          channelDescription: 'Channel for daily reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("✅ Daily notification scheduled!");
  }


  /// Schedule a periodic notification (e.g., every 3 hours)
  Future<void> schedulePeriodicNotifications() async {
    print("⏳ Scheduling periodic notifications...");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Did you know?',
      'Here\'s a fun fact: MGPT is awesome!',
      _nextInstanceOfTime(DateTime.now().hour + 3, DateTime.now().minute), // Next 3-hour interval
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'periodic_notification_channel',
          'Periodic Notifications',
          channelDescription: 'Channel for periodic notifications',
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("✅ Periodic notifications scheduled!");
  }

  /// Helper function to schedule notifications at the correct local time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    tz.initializeTimeZones();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    print("📅 Current Time: $now");
    print("📌 Scheduled Time Before Adjustment: $scheduledDate");

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print("🔄 Adjusted Scheduled Time: $scheduledDate");
    }

    return scheduledDate;
  }

}
