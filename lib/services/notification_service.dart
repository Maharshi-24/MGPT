import 'dart:async';
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

  late Timer _timer; // Timer to handle periodic notifications every hour
  int _messageIndex = 0; // Index to track which message to show

  // List of periodic messages (every 1 hour)
  final List<String> _periodicMessages = [
    "Haven't chatted in a while? Your AI is here to help—ask me anything!",
    "Need assistance? Your AI is ready to chat. Let’s continue where we left off!",
    "Stuck on something? Your AI assistant is here to help—just ask!",
    "It’s been a while! Have any questions today?"
  ];

  // List of daily tips (at 9 AM)
  final List<String> _dailyTips = [
    "Did you know? You can ask AI to summarize long documents instantly!",
    "Tip of the day: Use AI to generate creative ideas for your projects!",
    "Want to boost productivity? Try using AI for task automation!",
    "Fun fact: AI can help you draft emails, code snippets, and more—give it a try!",
    "AI insight: The best way to learn something new? Ask your AI!"
  ];

  Future<void> init() async {
    print("🚀 Initializing NotificationService...");

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

    // Start periodic notifications (every 1 hour)
    startPeriodicNotifications();

    // Schedule daily notification at 9 AM
    scheduleDailyNotification();

    print("✅ NotificationService initialized!");
  }

  // Configure local time zone
  Future<void> _configureLocalTimeZone() async {
    print("🌍 Configuring local timezone...");
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print("✅ Timezone configured: $timeZoneName");
  }

  // Request notification permissions for Android 13+ and iOS
  Future<void> _requestPermissions() async {
    print("🔔 Requesting notification permissions...");
    final status = await Permission.notification.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      print("⚠️ Notifications Denied. Opening App Settings...");
      openAppSettings(); // Opens system settings
    } else {
      print("✅ Notifications Allowed!");
    }
  }

  // Create necessary notification channels for Android 8.0+
  Future<void> _createNotificationChannels() async {
    print("📢 Creating notification channels...");
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

      const AndroidNotificationChannel periodicChannel = AndroidNotificationChannel(
        'periodic_notification_channel',
        'Periodic Notifications',
        description: 'Channel for periodic notifications every 1 hour',
        importance: Importance.max,
      );

      const AndroidNotificationChannel dailyTipChannel = AndroidNotificationChannel(
        'daily_tip_notification_channel',
        'Daily Tips',
        description: 'Channel for daily tips at 9 AM',
        importance: Importance.max,
      );

      await androidPlugin.createNotificationChannel(instantChannel);
      await androidPlugin.createNotificationChannel(periodicChannel);
      await androidPlugin.createNotificationChannel(dailyTipChannel);

      print("✅ Notification channels created!");
    }
  }

  // Show an instant notification (manual trigger)
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
      0,
      'You know...',
      'Eggs are the best🥚😋',
      notificationDetails,
    );

    print("✅ Instant notification displayed!");
  }

  // Start periodic notifications every 1 hour, cycling through messages
  void startPeriodicNotifications() {
    print("⏰ Starting periodic notifications...");
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      print("⏰ Timer triggered, showing periodic notification...");
      showPeriodicNotification(); // Trigger a notification every 1 hour
    });
  }

  // Show a periodic notification with the next message in the list
  Future<void> showPeriodicNotification() async {
    // Get the message to show
    String message = _periodicMessages[_messageIndex];

    // Cycle to the next message
    _messageIndex = (_messageIndex + 1) % _periodicMessages.length;

    print("🔔 Attempting to show periodic notification: $message");

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'periodic_notification_channel',
      'Periodic Notifications',
      channelDescription: 'Channel for periodic notifications every 1 hour',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      1, // Unique ID for periodic notifications
      'MGPT',
      message,
      notificationDetails,
    );

    print("✅ Periodic notification displayed!");
  }

  // Schedule daily notification at 9 AM
  Future<void> scheduleDailyNotification() async {
    print("🕒 Scheduling daily notification at 9 AM...");

    // Get a random message from the daily tips list
    String message = _dailyTips[DateTime.now().second % _dailyTips.length];

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);

    // If the scheduled time is already past, schedule for the next day
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    print("🕒 Scheduled time: $scheduledTime");

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'daily_tip_notification_channel',
      'Daily Tips',
      channelDescription: 'Channel for daily tips at 9 AM',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      2, // Unique ID for the daily notification
      'Tip of the Day',
      message,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required for exact timing
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("✅ Daily notification scheduled for: $scheduledTime");
  }

  // Stop the periodic notifications when not needed
  void stopPeriodicNotifications() {
    _timer.cancel();
    print("❌ Periodic notifications stopped.");
  }
}