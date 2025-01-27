import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:provider/provider.dart';
import '../widgets/chat/chat_message_list.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  bool _isDrawerOpen = false;
  double _drawerOffset = 0.0;
  final ScrollController _scrollController = ScrollController();
  bool _isPopupOpen = false; // Track if the popup menu is open
  final GlobalKey _tripleDotKey = GlobalKey(); // Key to locate the triple dots icon

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen to keyboard visibility changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Stop listening to keyboard visibility changes
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Called when the keyboard visibility changes
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0) {
      // Keyboard is open, scroll to the bottom
      _scrollToBottom();
    }
  }

  void _toggleDrawer() {
    HapticFeedback.lightImpact(); // Haptic feedback when toggling the drawer
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      _drawerOffset = _isDrawerOpen ? 1.0 : 0.0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _drawerOffset = (details.primaryDelta! / MediaQuery.of(context).size.width) + _drawerOffset;
      _drawerOffset = _drawerOffset.clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Handle popup menu item selection
  void _onPopupMenuItemSelected(String value) {
    HapticFeedback.lightImpact(); // Haptic feedback when an item is selected
    switch (value) {
      case 'view_details':
        print('View Details selected');
        break;
      case 'share':
        print('Share selected');
        break;
      case 'rename':
        print('Rename selected');
        break;
      case 'archive':
        print('Archive selected');
        break;
      case 'delete':
        print('Delete selected');
        break;
      case 'move_to_project':
        print('Move to Project selected');
        break;
      case 'temporary_chat':
        print('Temporary Chat selected');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return GestureDetector(
      onTap: () {
        chatProvider.focusNode.unfocus();
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                MediaQuery.of(context).size.width * 0.7 * _drawerOffset,
                0,
                0,
              ),
              child: Column(
                children: [
                  // Custom AppBar
                  AppBar(
                    title: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'MGPT',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    backgroundColor: Colors.black,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.short_text, // Default Flutter drawer icon
                        color: Colors.white,
                        size: 38,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact(); // Haptic feedback when opening drawer
                        _toggleDrawer(); // Toggle drawer state
                      },
                    ),
                    actions: [
                      // Edit icon on the left of the triple dots
                      IconButton(
                        icon: const Icon(
                          Icons.drive_file_rename_outline,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact(); // Haptic feedback when edit icon is pressed
                          print('Edit icon pressed');
                        },
                      ),
                      // Triple dots menu with ripple effect
                      InkWell(
                        key: _tripleDotKey, // Assign a key to the triple dots icon
                        borderRadius: BorderRadius.circular(20), // Ripple effect boundary
                        onTap: () {
                          HapticFeedback.lightImpact(); // Haptic feedback when opening popup menu
                          _showCustomPopupMenu(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ChatMessageList(
                      scrollController: _scrollController, // Pass the ScrollController
                    ),
                  ),
                  const ChatInput(),
                ],
              ),
            ),
            if (_isDrawerOpen || _drawerOffset > 0)
              GestureDetector(
                onTap: _toggleDrawer,
                child: Container(
                  color: Colors.black.withOpacity(0.5 * _drawerOffset),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                -MediaQuery.of(context).size.width * 0.7 * (1 - _drawerOffset),
                0,
                0,
              ),
              child: const CustomDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // Show custom popup menu with fade-in and scale-in animation
  void _showCustomPopupMenu(BuildContext context) {
    // Get the position of the triple dots icon
    final RenderBox renderBox = _tripleDotKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, // Left position (x-coordinate of the triple dots icon)
        offset.dy + renderBox.size.height, // Top position (below the triple dots icon)
        offset.dx + renderBox.size.width, // Right position
        offset.dy + renderBox.size.height + 100, // Bottom position
      ),
      items: <PopupMenuEntry<String>>[
        // First section
        const PopupMenuItem<String>(
          value: 'view_details',
          child: ListTile(
            leading: Icon(Icons.info_outline, color: Colors.white),
            title: Text('View Details', style: TextStyle(color: Colors.white)),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share_outlined, color: Colors.white),
            title: Text('Share', style: TextStyle(color: Colors.white)),
          ),
        ),
        // Divider
        const PopupMenuDivider(),
        // Second section
        const PopupMenuItem<String>(
          value: 'rename',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, color: Colors.white),
            title: Text('Rename', style: TextStyle(color: Colors.white)),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'archive',
          child: ListTile(
            leading: Icon(Icons.archive_outlined, color: Colors.white),
            title: Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.white),
            title: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'move_to_project',
          child: ListTile(
            leading: Icon(Icons.folder_open_outlined, color: Colors.white),
            title: Text('Move to Project', style: TextStyle(color: Colors.white)),
          ),
        ),
        // Divider
        const PopupMenuDivider(),
        // Third section
        const PopupMenuItem<String>(
          value: 'temporary_chat',
          child: ListTile(
            leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
            title: Text('Temporary Chat', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      color: const Color(0xFF141414), // Background color of the popup menu
    ).then((value) {
      if (value != null) {
        _onPopupMenuItemSelected(value);
      }
    });
  }
}