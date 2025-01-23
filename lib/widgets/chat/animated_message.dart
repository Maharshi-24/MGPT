import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import '../../../utils/message_parser.dart';

class AnimatedMessage extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isFirstMessage; // Add this parameter

  const AnimatedMessage({
    super.key,
    required this.message,
    required this.isUser,
    required this.isFirstMessage, // Add this parameter
  });

  void _showMessageOptions(BuildContext context, Offset tapPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final messagePosition = renderBox.localToGlobal(Offset.zero);

    // Declare the overlayEntry variable
    late OverlayEntry overlayEntry;

    // Initialize the overlayEntry
    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        // Close the overlay when tapping anywhere on the screen
        onTap: () {
          overlayEntry.remove();
        },
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Transparent background to capture taps
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              // Floating container with options
              Positioned(
                right: 16, // Align to the right
                top: isFirstMessage
                    ? messagePosition.dy + renderBox.size.height + 10 // Below the bubble for the first message
                    : messagePosition.dy - 150, // Above the bubble for other messages
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOptionButton(
                        icon: Icons.content_copy_outlined,
                        label: 'Copy',
                        onTap: () {
                          // Copy the message to clipboard
                          Clipboard.setData(ClipboardData(text: message));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                          overlayEntry.remove(); // Close the overlay
                        },
                      ),
                      const SizedBox(height: 12), // Add a vertical gap
                      _buildOptionButton(
                        icon: Icons.text_snippet_outlined,
                        label: 'Select Text',
                        onTap: () {
                          // Implement text selection logic
                          overlayEntry.remove(); // Close the overlay
                        },
                      ),
                      const SizedBox(height: 12), // Add another vertical gap
                      _buildOptionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit Message',
                        onTap: () {
                          // Implement message editing logic
                          overlayEntry.remove(); // Close the overlay
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Insert the overlay into the overlay stack
    Overlay.of(context).insert(overlayEntry);
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

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
      child: GestureDetector(
        onLongPress: () {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final tapPosition = renderBox.localToGlobal(Offset.zero);
          _showMessageOptions(context, tapPosition);
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
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.grey.withOpacity(0.3),
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
      ),
    );
  }
}