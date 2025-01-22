import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'animated_message.dart';
import 'thinking_indicator.dart';

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
        // Scroll to bottom only when a new message is added
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
            // Scroll-to-bottom button with fade animation
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showScrollToBottomButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _scrollToBottom,
                    child: Container(
                      width: 50, // Fixed size for the button
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[850], // Button color
                        shape: BoxShape.circle, // Make it circular
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildImageIcon(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageIcon() {
    try {
      return Image.asset(
        'assets/images/scroll-to-bottom.png', // Ensure this path is correct
        width: 20,
        height: 20,
        color: Colors.white,
      );
    } catch (e) {
      print('Error loading image: $e');
      return Icon(Icons.error); // Fallback icon if the image fails to load
    }
  }
}