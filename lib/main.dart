import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maharshi Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => ChatProvider(),
        child: const ChatScreen(),
      ),
    );
  }
}

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

class AnimatedMessage extends StatelessWidget {
  final String message;
  final bool isUser;

  const AnimatedMessage({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[50] : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isUser ? 12 : 0),
                topRight: Radius.circular(isUser ? 0 : 12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _parseMessage(message),
          ),
        ),
      ),
    );
  }

  Widget _parseMessage(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: _parseInlineFormatting(text),
      ),
    );
  }

  List<TextSpan> _parseInlineFormatting(String text) {
    final regex = RegExp(r'\*\*(.*?)\*\*|__(.*?)__|\*(.*?)\*|_(.*?)_');
    final matches = regex.allMatches(text);
    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
        ));
      }

      final boldText = match.group(1) ?? match.group(2);
      final italicText = match.group(3) ?? match.group(4);

      if (boldText != null) {
        spans.add(TextSpan(
          text: boldText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (italicText != null) {
        spans.add(TextSpan(
          text: italicText,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
      ));
    }

    return spans;
  }
}

class ThinkingIndicator extends StatelessWidget {
  const ThinkingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: context.read<ChatProvider>().textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              context.read<ChatProvider>().sendMessage();
            },
            backgroundColor: Colors.blue,
            elevation: 0,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ChatProvider with ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isThinking = false;

  Future<void> sendMessage() async {
    final userMessage = textController.text.trim();
    if (userMessage.isEmpty) return;

    messages.add({'text': userMessage, 'isUser': true});
    isThinking = true;
    notifyListeners();

    textController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.168.46:5000/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final botMessage = jsonDecode(response.body)['response'];
        messages.add({'text': botMessage, 'isUser': false});
      } else {
        throw Exception('Failed to load response');
      }
    } catch (e) {
      messages.add({'text': 'Error: $e', 'isUser': false});
    } finally {
      isThinking = false;
      notifyListeners();
    }
  }
}