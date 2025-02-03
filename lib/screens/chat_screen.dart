import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/chat/chat_message_list.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/common/scroll_to_bottom_button.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../widgets/chat/chat_app_bar.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0) {
      _scrollToBottom();
    }
  }

  void _toggleDrawer() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      _drawerOffset = _isDrawerOpen ? 1.0 : 0.0;
    });
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
    bool showScrollDownIcon = chatProvider.messages.isNotEmpty &&
        chatProvider.messages.last['text'] != 'What can I help with?';

    return GestureDetector(
      onTap: () => chatProvider.focusNode.unfocus(),
      onHorizontalDragUpdate: (details) {
        setState(() {
          _drawerOffset = (_drawerOffset + details.primaryDelta! / MediaQuery.of(context).size.width)
              .clamp(0.0, 1.0);
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _isDrawerOpen = _drawerOffset > 0.5;
          _drawerOffset = _isDrawerOpen ? 1.0 : 0.0;
        });
      },
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
                  ChatAppBar(onDrawerToggle: _toggleDrawer),
                  Expanded(
                    child: ChatMessageList(scrollController: _scrollController),
                  ),
                  const ChatInput(),
                ],
              ),
            ),
            if (_isDrawerOpen || _drawerOffset > 0)
              GestureDetector(
                onTap: _toggleDrawer,
                child: Container(color: Colors.black.withOpacity(0.5 * _drawerOffset)),
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
            if (showScrollDownIcon)
              Positioned(
                bottom: 150,
                right: 480,
                child: ScrollToBottomButton(onPressed: _scrollToBottom),
              ),
          ],
        ),
      ),
    );
  }
}
