import 'package:flutter/material.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MChat'),
        backgroundColor: Colors.blue.shade400, // Adjust the color to match the design
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