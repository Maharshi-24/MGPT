import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatOptionsMenu extends StatelessWidget {
  const ChatOptionsMenu({super.key});

  void _showCustomPopupMenu(BuildContext context, GlobalKey key) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width, offset.dy + renderBox.size.height + 100,
      ),
      items: [
        _buildPopupMenuItem(context, 'view_details', Icons.info_outline, 'View Details'),
        _buildPopupMenuItem(context, 'share', Icons.share_outlined, 'Share'),
        const PopupMenuDivider(),
        _buildPopupMenuItem(context, 'rename', Icons.edit_outlined, 'Rename'),
        _buildPopupMenuItem(context, 'archive', Icons.archive_outlined, 'Archive'),
        _buildPopupMenuItem(context, 'delete', Icons.delete_outline, 'Delete'),
        _buildPopupMenuItem(context, 'move_to_project', Icons.folder_open_outlined, 'Move to Project'),
        const PopupMenuDivider(),
        _buildPopupMenuItem(context, 'temporary_chat', Icons.chat_bubble_outline, 'Temporary Chat'),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: const Color(0xFF141414),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(BuildContext context, String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      onTap: () => HapticFeedback.lightImpact(), // Haptic feedback on tap
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey _tripleDotKey = GlobalKey();

    return InkWell(
      key: _tripleDotKey,
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.lightImpact(); // Light haptic feedback when opening the menu
        _showCustomPopupMenu(context, _tripleDotKey);
      },
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }
}
