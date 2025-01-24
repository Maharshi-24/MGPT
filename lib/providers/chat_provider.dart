import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class ChatProvider with ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  List<Map<String, dynamic>> messages = [];
  bool isThinking = false; // Tracks whether the AI is generating a response

  // Get the current user ID
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'defaultUser';

  // Method to update a message and re-trigger the AI response
  Future<void> editMessage(int index, String newMessage) async {
    if (index >= 0 && index < messages.length) {
      print('Editing message at index $index: $newMessage'); // Debug log

      // Update the message text
      messages[index]['text'] = newMessage;
      notifyListeners(); // Notify listeners to update the UI

      // Remove all messages after the edited message
      messages = messages.sublist(0, index + 1);
      notifyListeners();

      // Re-trigger the AI response
      await sendMessage(newMessage);
    } else {
      print('Invalid index: $index'); // Debug log
    }
  }

  // Method to send a message to the backend
  Future<void> sendMessage([String? message]) async {
    final userMessage = message ?? textController.text.trim();
    if (userMessage.isEmpty) return;

    print('Sending message: $userMessage'); // Debug log

    // Add the user's message to the list
    messages.add({'text': userMessage, 'isUser': true});
    isThinking = true; // Set thinking state to true
    notifyListeners();

    textController.clear();

    try {
      // Send the message to the backend
      final request = http.Request('POST', Uri.parse('http://172.20.176.1:5000/api/chat'))
        ..headers['Content-Type'] = 'application/json'
    ..body = jsonEncode({'message': userMessage, 'userId': userId});

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
    String botResponse = '';
    messages.add({'text': '', 'isUser': false}); // Add an empty message for the bot

    // Stream the bot's response
    await streamedResponse.stream.transform(utf8.decoder).listen((chunk) {
    if (chunk.startsWith('data: ')) {
    final jsonString = chunk.substring(6).trim();
    final jsonResponse = jsonDecode(jsonString);
    final content = jsonResponse['response'];

    print('Received chunk: $content'); // Debug log

    // Update the bot's response incrementally
    botResponse += content;
    messages.last['text'] = botResponse;
    notifyListeners(); // Notify listeners to update the UI and scroll down
    }
    }).asFuture();
    } else {
    throw Exception('Failed to load response');
    }
    } catch (e) {
    print('Error sending message: $e'); // Debug log
    messages.add({'text': 'Error: $e', 'isUser': false});
    } finally {
    isThinking = false; // Set thinking state to false
    notifyListeners();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}