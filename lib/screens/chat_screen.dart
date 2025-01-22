import 'package:flutter/material.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maharshi Chat'),
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