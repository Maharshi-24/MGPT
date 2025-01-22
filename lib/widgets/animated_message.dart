import 'package:flutter/material.dart';
import '../utils/message_parser.dart';

class AnimatedMessage extends StatelessWidget {
  final String message;
  final bool isUser;

  const AnimatedMessage({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[50] : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isUser ? 12 : 0),
                topRight: Radius.circular(isUser ? 0 : 12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: MessageParser.parse(message),
          ),
        ),
      ),
    );
  }
}