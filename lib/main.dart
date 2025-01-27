import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maharshi_chat/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'screens/auth_gate.dart'; // Import your AuthGate or main screen
import 'providers/chat_provider.dart'; // Import your ChatProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
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
      ),
      home: const SplashScreenWrapper(), // Start with the splash screen
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

    // Navigate to the main app screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ChatProvider(),
            child: const AuthGate(), // Replace with your main screen
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Show the custom splash screen
  }
}