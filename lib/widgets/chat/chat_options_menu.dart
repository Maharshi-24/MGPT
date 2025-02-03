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
      items: const [
        PopupMenuItem<String>(
          value: 'view_details',
          child: ListTile(
            leading: Icon(Icons.info_outline, color: Colors.white),
            title: Text('View Details', style: TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share_outlined, color: Colors.white),
            title: Text('Share', style: TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'rename',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, color: Colors.white),
            title: Text('Rename', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: const Color(0xFF141414),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey _tripleDotKey = GlobalKey();

    return InkWell(
      key: _tripleDotKey,
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.lightImpact();
        _showCustomPopupMenu(context, _tripleDotKey);
      },
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }
}
