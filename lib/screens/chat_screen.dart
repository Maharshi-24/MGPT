import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return GestureDetector(
      onTap: () {
        // Unfocus the text field when tapping outside
        chatProvider.focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black87, // Dark background
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft, // Align text to the left
            child: Text(
              'MGPT',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.black87,
          // Slightly lighter dark color for app bar
          elevation: 0,
          leading: Builder(
            builder: (context) =>
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  // Menu icon for the drawer
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // Open the drawer
                  },
                ),
          ),
        ),
        drawer: _buildDrawer(context), // Add the drawer
        body: const Column(
          children: [
            Expanded(
              child: ChatMessageList(),
            ),
            ChatInput(),
          ],
        ),
      ),
    );
  }

  // Function to build the drawer
  // Function to build the drawer
  Widget _buildDrawer(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20), // Pointy corners at the top
        bottomRight: Radius.circular(20),
      ),
      child: Drawer(
        backgroundColor: const Color(0xFF0C0C0C),
        // Solid dark background for the drawer
        elevation: 0,
        // Remove shadow
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
                  fillColor: const Color(0xFF292929),
                  // Solid dark grey for search bar
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
                  color: Color(0xFF0C0C0C)
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF0C0C0C),
                    // Solid dark grey for user avatar
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