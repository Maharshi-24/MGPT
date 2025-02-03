import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:firebase_auth/firebase_auth.dart';
import 'changelog_screen.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'N/A';
        _userEmail = user.email ?? 'N/A';
        _userPhone = user.phoneNumber ?? 'xxxx-xxx-xxx';
        _userPhotoUrl = user.photoURL;
      });
    }
  }

  Widget _buildListTile(
      IconData icon,
      String title, {
        String? subtitle,
        Color? iconColor,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey[400]))
          : null,
      onTap: () {
        // Add haptic feedback
        HapticFeedback.lightImpact();
        if (onTap != null) onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact(); // Add haptic feedback
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _userPhotoUrl != null
                    ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(_userPhotoUrl!),
                )
                    : CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text(
                  _userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildListTile(Icons.email_outlined, 'Email', subtitle: _userEmail),
          _buildListTile(Icons.phone_outlined, 'Phone number',
              subtitle: _userPhone),
          _buildListTile(Icons.palette_outlined, 'Customize'),
          _buildListTile(Icons.security, 'Data Controls'),
          _buildListTile(Icons.mic, 'Voice'),
          _buildListTile(Icons.info_outline, 'About'),
          _buildListTile(Icons.new_releases, "What's New", onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ChangelogScreen(onDone: () {}),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ));
          }),
          _buildListTile(Icons.notifications, 'Test Notification', onTap: () async {
            print("🔔 Sending test notification...");
            await _notificationService.showInstantNotification();
            print("✅ Notification Triggered");
          }),
          _buildListTile(Icons.logout, 'Sign out', iconColor: Colors.red, onTap: () async {
            await _auth.signOut();
            // Navigate to the login page and remove all previous routes from the stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace with your login screen widget
                  (Route<dynamic> route) => false, // This ensures that all previous routes are removed
            );
          }),
        ],
      ),
    );
  }
}