import 'package:flutter/material.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Dark background
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft, // Align text to the left
          child: Text(
            'ARIA',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black87, // Slightly lighter dark color for app bar
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(),
          ),
          const ChatInput(),
        ],
      ),
    );
  }
}