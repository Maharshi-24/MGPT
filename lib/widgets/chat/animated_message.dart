import 'package:flutter/material.dart';
import '../../../utils/message_parser.dart';

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
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: isUser ? 1.0 : -1.0,
            child: child,
          ),
        );
      },
      child: Padding(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              // Handle the tap event here
              print("Message tapped: $message");
            },
            borderRadius: BorderRadius.circular(16), // Ensures the ripple matches the container shape
            splashColor: Colors.grey.withOpacity(0.3), // Custom splash color
            child: isUser
                ? Container(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: MessageParser.parse(message, context),
                )
                : MessageParser.parse(message, context),
          ),
        ),
      ),
    );
  }
}
