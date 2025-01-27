import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool isExpanded = false; // To track if the text field is expanded
  bool isIconsVisible = true; // To track if the icons are visible

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Show the plus button when icons are hidden
              // Show the plus button when icons are hidden
              if (!isIconsVisible)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey, // Set background color to grey
                    shape: BoxShape.circle, // To keep the plus button circular
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isIconsVisible = true; // Restore icons when plus button is tapped
                        isExpanded = false; // Collapse the text field
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),


              const SizedBox(width: 8),

              // Show icons when they are visible and text field is not expanded
              if (isIconsVisible && !isExpanded)
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.image_outlined, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.folder_outlined, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.cloud_queue_outlined, color: Colors.white),
                    ),
                  ],
                ),

              const SizedBox(width: 8),

              // Smooth Animated Expansion for Text Field
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: GestureDetector(
                    onTap: () {
                      // When the text field is tapped, expand it and hide the icons
                      setState(() {
                        isExpanded = true;
                        isIconsVisible = false; // Hide icons and show plus button
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: chatProvider.textController,
                              focusNode: chatProvider.focusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Message',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              enabled: !chatProvider.isThinking,
                              onTap: () {
                                HapticFeedback.selectionClick(); // Light vibration for text field tap
                                setState(() {
                                  isExpanded = true;
                                  isIconsVisible = false; // Hide icons and show plus button
                                });
                              },
                              onSubmitted: (value) {
                                if (!chatProvider.isThinking) {
                                  HapticFeedback.lightImpact(); // Light vibration for submission
                                  chatProvider.sendMessage();
                                }
                              },
                            ),
                          ),
                          const Icon(Icons.mic_outlined, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  onPressed: () {
                    if (!chatProvider.isThinking) {
                      HapticFeedback.lightImpact(); // Light vibration for send button tap
                      chatProvider.sendMessage();
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
