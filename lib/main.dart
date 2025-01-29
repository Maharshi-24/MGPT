import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maharshi_chat/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'screens/auth_gate.dart';
import 'providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ChatProvider(),
            child: const AuthGate(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
