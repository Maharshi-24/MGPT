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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (_) => ChatProvider(),
        child: ChatScreen(),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maharshi Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
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
                  itemCount: chatProvider.messages.length + (chatProvider.isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < chatProvider.messages.length) {
                      final message = chatProvider.messages[index];
                      return ListTile(
                        title: _formatMessage(message['text']),
                        subtitle: Text(message['isUser'] ? 'You' : 'Bot'),
                        tileColor: message['isUser'] ? Colors.blue[50] : Colors.grey[200],
                      );
                    } else {
                      return const ListTile(
                        title: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: context.read<ChatProvider>().textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    context.read<ChatProvider>().sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatMessage(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        continue;
      } else if (line.startsWith('# ')) {
        // Heading 1
        widgets.add(Text(
          line.substring(2),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('## ')) {
        // Heading 2
        widgets.add(Text(
          line.substring(3),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('* ') || line.startsWith('- ')) {
        // Bullet points
        widgets.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• '),
            Expanded(
              child: _parseInlineFormatting(line.substring(2)),
            ),
          ],
        ));
      } else if (line.trim() == '========' || line.trim() == '--------------') {
        // Horizontal line separator
        widgets.add(const Divider(
          thickness: 1,
          color: Colors.grey,
        ));
      } else if (line.trim() == '**') {
        // Ignore standalone **
        continue;
      } else {
        // Parse inline formatting for regular text
        widgets.add(_parseInlineFormatting(line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseInlineFormatting(String text) {
    final regex = RegExp(r'\*\*(.*?)\*\*|__(.*?)__|\*(.*?)\*|_(.*?)_');
    final matches = regex.allMatches(text);
    final spans = <TextSpan>[];

    int currentIndex = 0;

    for (var match in matches) {
      // Add text before the match
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: const TextStyle(fontSize: 16),
        ));
      }

      // Add the matched text with appropriate style
      final boldText = match.group(1) ?? match.group(2);
      final italicText = match.group(3) ?? match.group(4);

      if (boldText != null) {
        spans.add(TextSpan(
          text: boldText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ));
      } else if (italicText != null) {
        spans.add(TextSpan(
          text: italicText,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ));
      }

      currentIndex = match.end;
    }

    // Add remaining text after the last match
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: const TextStyle(fontSize: 16),
      ));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: spans,
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