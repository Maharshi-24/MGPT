import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatProvider with ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  List<Map<String, dynamic>> messages = [];
  bool isThinking = false;
  final String userId = 'uniqueUserId';

  Future<void> sendMessage() async {
    final userMessage = textController.text.trim();
    if (userMessage.isEmpty) return;

    messages.add({'text': userMessage, 'isUser': true});
    isThinking = true;
    notifyListeners();

    textController.clear();

    try {
      final request = http.Request('POST', Uri.parse('http://172.20.176.1:5000/api/chat'))
        ..headers['Content-Type'] = 'application/json'
    ..body = jsonEncode({'message': userMessage, 'userId': userId});

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
    String botResponse = '';
    messages.add({'text': '', 'isUser': false}); // Add an empty message for the bot

    await streamedResponse.stream.transform(utf8.decoder).listen((chunk) {
    // Parse the chunk (assuming it's in the format `data: {"response":"..."}`)
    if (chunk.startsWith('data: ')) {
    final jsonString = chunk.substring(6).trim();
    final jsonResponse = jsonDecode(jsonString);
    final content = jsonResponse['response'];

    // Update the bot's response incrementally
    botResponse += content;
    messages.last['text'] = botResponse;
    notifyListeners();
    }
    }).asFuture();
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

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}