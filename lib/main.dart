import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maharshi Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // Scroll to the bottom when new messages are added
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
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
                        title: Text(message['text']),
                        subtitle: Text(message['isUser'] ? 'You' : 'Bot'),
                        tileColor: message['isUser'] ? Colors.blue[50] : Colors.grey[200],
                      );
                    } else {
                      // Show a loading indicator when the bot is thinking
                      return ListTile(
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
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
}

class ChatProvider with ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isThinking = false;

  Future<void> sendMessage() async {
    final userMessage = textController.text.trim();
    if (userMessage.isEmpty) return;

    // Add user message to the list
    messages.add({'text': userMessage, 'isUser': true});
    isThinking = true;
    notifyListeners();

    // Clear the input field
    textController.clear();

    // Send the message to the backend
    try {
      final response = await http.post(
        Uri.parse('http://192.168.168.46:5000/api/chat'), // Replace with your backend URL
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