import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_options_menu.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onDrawerToggle;
  const ChatAppBar({super.key, required this.onDrawerToggle});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return AppBar(
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
        icon: const Icon(Icons.short_text, color: Colors.white, size: 38),
        onPressed: onDrawerToggle,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.drive_file_rename_outline, color: Colors.white),
          onPressed: chatProvider.clearMessages,
        ),
        const ChatOptionsMenu(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
