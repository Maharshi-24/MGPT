import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../common/scroll_to_bottom_button.dart';
import 'animated_message.dart';
import 'thinking_indicator.dart';

class ChatMessageList extends StatefulWidget {
  final ScrollController scrollController; // Accept ScrollController from parent

  const ChatMessageList({super.key, required this.scrollController});

  @override
  _ChatMessageListState createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  bool _showScrollToBottomButton = false;
  bool _userHasInterruptedScroll = false; // Track if the user has interrupted auto-scroll
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll); // Use the passed ScrollController
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll); // Remove listener
    super.dispose();
  }

  void _onScroll() {
    // Check if the user has scrolled up manually
    if (widget.scrollController.offset < widget.scrollController.position.maxScrollExtent - 100) {
      if (!_userHasInterruptedScroll) {
        setState(() {
          _userHasInterruptedScroll = true; // User has interrupted auto-scroll
        });
      }

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
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Reset the flag when the user clicks the scroll-to-bottom button
    setState(() {
      _userHasInterruptedScroll = false;
    });
  }

  void _autoScrollToBottom() {
    if (!_userHasInterruptedScroll && widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Auto-scroll to bottom when new messages are added or the bot is thinking
        if (chatProvider.messages.length > _previousMessageCount || chatProvider.isThinking) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoScrollToBottom();
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
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: chatProvider.messages.length + (chatProvider.isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < chatProvider.messages.length) {
                    final message = chatProvider.messages[index];
                    // Check if this is the first message in the chat
                    final isFirstMessage = index == 0;
                    return AnimatedMessage(
                      key: ValueKey(message['text']),
                      message: message['text'],
                      isUser: message['isUser'],
                      isFirstMessage: isFirstMessage, // Pass the parameter
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