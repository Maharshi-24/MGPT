import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey _tripleDotKey = GlobalKey();

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

  void _clearMessages() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return GestureDetector(
      onTap: () {
        chatProvider.focusNode.unfocus();
      },
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
                        Icons.short_text,
                        color: Colors.white,
                        size: 38,
                      ),
                      onPressed: _toggleDrawer,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.drive_file_rename_outline,
                          color: Colors.white,
                        ),
                        onPressed: _clearMessages,
                      ),
                      InkWell(
                        key: _tripleDotKey,
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          HapticFeedback.lightImpact();
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
                      scrollController: _scrollController,
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

  void _showCustomPopupMenu(BuildContext context) {
    final RenderBox renderBox = _tripleDotKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 100,
      ),
      items: <PopupMenuEntry<String>>[
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
        const PopupMenuDivider(),
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
        const PopupMenuDivider(),
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
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFF141414),
    );
  }
}
