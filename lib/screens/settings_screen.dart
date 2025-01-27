import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Widget _buildListTile(IconData icon, String title, {String? subtitle, Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[400])) : null,
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
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildListTile(Icons.email, 'Email', subtitle: _userEmail),
          _buildListTile(Icons.phone, 'Phone number', subtitle: _userPhone),
          _buildListTile(Icons.palette, 'Customize'),
          _buildListTile(Icons.security, 'Data Controls'),
          _buildListTile(Icons.mic, 'Voice'),
          _buildListTile(Icons.info, 'About'),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Sign out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}

