import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return GestureDetector(
      onTap: () {
        // Unfocus the text field when tapping outside
        chatProvider.focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black87, // Dark background
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft, // Align text to the left
            child: Text(
              'MGPT',
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
      ),
    );
  }
}