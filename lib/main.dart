import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maharshi_chat/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'screens/auth_gate.dart';
import 'providers/chat_provider.dart';
import 'services/notification_service.dart'; // Import the notification service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp()); // Run the app first

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyNotification();
  await notificationService.schedulePeriodicNotifications();
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maharshi Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'VT323'),
          bodyMedium: TextStyle(fontFamily: 'VT323'),
          bodySmall: TextStyle(fontFamily: 'VT323'),
          titleLarge: TextStyle(fontFamily: 'VT323'),
          titleMedium: TextStyle(fontFamily: 'VT323'),
          titleSmall: TextStyle(fontFamily: 'VT323'),
        ),
      ),
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({Key? key}) : super(key: key);

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) { // Prevents navigation if widget is destroyed
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => ChatProvider(),
                child: const AuthGate(),
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
