import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isDrawerOpen = false; // Track whether the drawer is open
  double _drawerOffset = 0.0; // Track the swipe offset

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      _drawerOffset = _isDrawerOpen ? 1.0 : 0.0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Calculate the swipe offset
    setState(() {
      _drawerOffset = (details.primaryDelta! / MediaQuery.of(context).size.width) + _drawerOffset;
      _drawerOffset = _drawerOffset.clamp(0.0, 1.0); // Clamp the value between 0 and 1
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // Determine if the drawer should be opened or closed based on the swipe velocity
    if (_drawerOffset > 0.5) {
      setState(() {
        _isDrawerOpen = true;
        _drawerOffset = 1.0;
      });
    } else {
      setState(() {
        _isDrawerOpen = false;
        _drawerOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return GestureDetector(
      onTap: () {
        // Unfocus the text field when tapping outside
        chatProvider.focusNode.unfocus();
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Scaffold(
        backgroundColor: Colors.black87, // Dark background
        body: Stack(
          children: [
            // Main content (including AppBar)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Animation duration
              curve: Curves.easeInOut, // Smooth animation
              transform: Matrix4.translationValues(
                MediaQuery.of(context).size.width * 0.7 * _drawerOffset,
                0,
                0,
              ), // Push content to the right
              child: Column(
                children: [
                  // Custom AppBar
                  AppBar(
                    title: const Align(
                      alignment: Alignment.centerLeft, // Align text to the left
                      child: Text(
                        'MGPT',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    backgroundColor: Colors.black87, // Slightly lighter dark color for app bar
                    elevation: 0,
                    leading: IconButton(
                      icon: Image.asset(
                        'assets/images/drawer_icon.png', // Path to your custom drawer icon
                        width: 24, // Adjust the size as needed
                        height: 24,
                        color: Colors.white, // Tint the icon white
                      ),
                      onPressed: _toggleDrawer, // Toggle drawer state
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: const ChatMessageList(),
                  ),
                  const ChatInput(),
                ],
              ),
            ),

            // Backdrop (Scrim) effect
            if (_isDrawerOpen || _drawerOffset > 0)
              GestureDetector(
                onTap: _toggleDrawer, // Close the drawer when tapping the backdrop
                child: Container(
                  color: Colors.black.withOpacity(0.5 * _drawerOffset), // Semi-transparent backdrop
                ),
              ),

            // Drawer
            AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Animation duration
              curve: Curves.easeInOut, // Smooth animation
              transform: Matrix4.translationValues(
                -MediaQuery.of(context).size.width * 0.7 * (1 - _drawerOffset),
                0,
                0,
              ), // Slide drawer in/out
              child: _buildDrawer(context), // Custom drawer
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the drawer
  Widget _buildDrawer(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20), // Pointy corners at the top
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7, // Drawer width (70% of screen)
        color: const Color(0xFF0C0C0C), // Solid dark background for the drawer
        child: Column(
          children: [
            // Drawer header with the same height as the AppBar
            Container(
              height: kToolbarHeight, // Same height as the AppBar
              color: const Color(0xFF0C0C0C), // Solid dark color for the header
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF292929), // Solid dark grey for search bar
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

            // Space for previously created chats (empty for now)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Placeholder for chat history (will be populated later)
                  // Example:
                  // ListTile(
                  //   leading: Icon(Icons.chat, color: Colors.white),
                  //   title: Text('Chat 1', style: TextStyle(color: Colors.white)),
                  //   onTap: () {
                  //     // Navigate to the selected chat
                  //   },
                  // ),
                ],
              ),
            ),

            // User profile section at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0C0C0C),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF0C0C0C), // Solid dark grey for user avatar
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Name', // Placeholder for user name
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'user@example.com', // Placeholder for user email
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}