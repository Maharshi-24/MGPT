import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../common/scroll_to_bottom_button.dart';
import 'animated_message.dart';
import 'thinking_indicator.dart';
import '../../common/scroll_to_bottom_button.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  _ChatMessageListState createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = false;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset < _scrollController.position.maxScrollExtent - 100) {
      if (!_showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = true;
        });
      }
    } else {
      if (_showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.messages.length > _previousMessageCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
          _previousMessageCount = chatProvider.messages.length;
        }

        return Stack(
          children: [
            if (chatProvider.messages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'What can I help with?',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
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
              ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showScrollToBottomButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: ScrollToBottomButton(
                    onPressed: _scrollToBottom,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}