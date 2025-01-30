import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
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

    // Initialize timezones
    await _configureLocalTimeZone();

    // Request notification permissions
    await _requestPermissions();

    // Create notification channels
    await _createNotificationChannels();
  }

  /// Configure local timezone using flutter_timezone
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print("✅ Timezone configured: $timeZoneName");
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

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'instant_notification_channel',
      'Instant Notifications',
      channelDescription: 'Channel for instant notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      2,
      'You know...',
      'Eggs are the best🥚😋',
      notificationDetails,
    );

    print("✅ Notification should be displayed!");
  }

  /// Schedule a daily notification at a fixed time (e.g., 1:05 PM)
  Future<void> scheduleDailyNotification() async {
    print("🕒 Scheduling daily notification...");

    // Schedule for 1:05 PM in the device's local timezone
    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(14, 26); // 1:05 PM
    print("📅 Scheduled time: $scheduledTime");

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'daily_notification_channel',
      'Daily Notifications',
      channelDescription: 'Channel for daily reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Reminder',
      'It\'s time for your daily notification!',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // This is the correct usage
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("✅ Daily notification scheduled!");
  }

  /// Schedule periodic notifications (e.g., every minute)
  Future<void> schedulePeriodicNotifications() async {
    print("⏳ Scheduling periodic notifications...");

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'periodic_notification_channel',
      'Periodic Notifications',
      channelDescription: 'Channel for periodic notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      'Periodic Notification',
      'This is a periodic notification!',
      RepeatInterval.everyMinute,  // Set the interval for periodic notifications
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required in v18.0.1+
    );

    print("✅ Periodic notifications scheduled!");
  }



  /// Helper function to schedule notifications at the correct local time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
