import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'animated_message.dart';
import 'thinking_indicator.dart';

class ChatMessageList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  ChatMessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: chatProvider.messages.length + (chatProvider.isThinking ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < chatProvider.messages.length) {
              final message = chatProvider.messages[index];
              return AnimatedMessage(
                key: ValueKey(message['text']),
                message: message['text'],
                isUser: message['isUser'],
              );
            } else {
              return const ThinkingIndicator();
            }
          },
        );
      },
    );
  }
}