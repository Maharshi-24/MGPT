import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController(); // Add ScrollController

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
                    backgroundColor: Colors.black87,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.short_text, // Default Flutter drawer icon
                        color: Colors.white,
                        size: 38,
                      ),
                      onPressed: _toggleDrawer, // Toggle drawer state
                    ),
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
}