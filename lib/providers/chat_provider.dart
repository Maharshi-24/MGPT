import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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