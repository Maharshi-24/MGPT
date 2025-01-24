import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'drawer_header.dart';
import '../../screens/login_screen.dart'; // Import the LoginScreen

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FocusNode _searchFocusNode = FocusNode();
  double _drawerWidth = 0.7;
  double _maxStretch = 1.0;
  double _currentDragOffset = 0.0;

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('Logout successful!'); // Debug log
      // No need to navigate manually; AuthGate will handle it
    } catch (e) {
      print('Logout failed: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          _currentDragOffset = details.primaryDelta! / screenWidth;
          _drawerWidth = (_drawerWidth + _currentDragOffset).clamp(0.7, _maxStretch);
        });
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        setState(() {
          _drawerWidth = 0.7;
          _currentDragOffset = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: screenWidth * _drawerWidth,
        child: ClipPath(
          clipper: _DrawerClipper(),
          child: Container(
            color: const Color(0xFF0C0C0C),
            child: Column(
              children: [
                const CustomDrawerHeader(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: const Color(0xFF292929),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(36),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.drive_file_rename_outline, color: Colors.white),
                        onPressed: () {
                          // Handle the edit icon press
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Chats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: const [
                      // Placeholder for chat history
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C0C0C),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF0C0C0C),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'user@example.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width + 20, 0);
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height + 20);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}