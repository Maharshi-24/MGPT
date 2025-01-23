import 'package:flutter/material.dart';
import 'drawer_header.dart'; // Import your custom drawer header

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FocusNode _searchFocusNode = FocusNode(); // FocusNode for the search bar
  double _drawerWidth = 0.7; // Initial width of the drawer (70% of screen width)
  double _maxStretch = 1.0; // Maximum stretch (100% of screen width)
  double _currentDragOffset = 0.0; // Current drag offset

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        // Unfocus the search bar when tapping outside
        _searchFocusNode.unfocus();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        // Calculate the drag offset
        setState(() {
          _currentDragOffset = details.primaryDelta! / screenWidth;
          _drawerWidth = (_drawerWidth + _currentDragOffset).clamp(0.7, _maxStretch);
        });
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        // Snap the drawer back to its original width when the drag ends
        setState(() {
          _drawerWidth = 0.7; // Reset to 70% of screen width
          _currentDragOffset = 0.0; // Reset drag offset
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Smooth animation
        width: screenWidth * _drawerWidth, // Dynamic width based on drag
        child: ClipPath(
          clipper: _DrawerClipper(), // Custom clipper for pointy edges
          child: Container(
            color: const Color(0xFF0C0C0C),
            child: Column(
              children: [
                const CustomDrawerHeader(), // Use the renamed widget here
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocusNode, // Assign the FocusNode to the search bar
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
                      const SizedBox(width: 8), // Add some space between the search bar and the icon
                      IconButton(
                        icon: const Icon(Icons.drive_file_rename_outline, color: Colors.white),
                        onPressed: () {
                          // Handle the edit icon press
                        },
                      ),
                    ],
                  ),
                ),
                // Add a divider line between the search bar and "Chats"
                const Divider(
                  color: Colors.grey, // Color of the divider line
                  height: 1, // Height of the divider line
                  thickness: 1, // Thickness of the divider line
                  indent: 16, // Left padding for the divider
                  endIndent: 16, // Right padding for the divider
                ),
                const SizedBox(height: 16), // Add space below the divider
                // Add the "Chats" heading below the search bar
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

// Custom clipper to make the right edges of the drawer pointy
class _DrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // Start at the top-left corner
    path.lineTo(size.width + 20, 0); // Move to the top-right corner (minus 20 for the pointy edge)
    path.lineTo(size.width, 20); // Create a diagonal line for the pointy edge
    path.lineTo(size.width, size.height + 20); // Move to the bottom-right corner (minus 20 for the pointy edge)
    path.lineTo(0, size.height); // Move to the bottom-left corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}