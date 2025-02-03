import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ChatProvider with ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  List<Map<String, dynamic>> messages = [];
  bool isThinking = false;
  bool _isStreaming = false;

  bool get isStreaming => _isStreaming;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'defaultUser';

  Future<void> editMessage(int index, String newMessage) async {
    if (index >= 0 && index < messages.length) {
      messages[index]['text'] = newMessage;
      notifyListeners();
      messages = messages.sublist(0, index + 1);
      notifyListeners();
      await sendMessage(newMessage);
    }
  }

  Future<void> sendMessage([String? message]) async {
    final userMessage = message ?? textController.text.trim();
    if (userMessage.isEmpty) return;

    messages.add({'text': userMessage, 'isUser': true});
    isThinking = true;
    _isStreaming = true;
    notifyListeners();
    textController.clear();

    try {
      final request = http.Request('POST', Uri.parse('https://maharshi-chat-backend.onrender.com/api/chat'))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({'message': userMessage, 'userId': userId});

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        String botResponse = '';
        messages.add({'text': '', 'isUser': false});

        await streamedResponse.stream.transform(utf8.decoder).listen((chunk) {
          if (!_isStreaming) return;
          if (chunk.startsWith('data: ')) {
            final jsonString = chunk.substring(6).trim();
            final jsonResponse = jsonDecode(jsonString);
            final content = jsonResponse['response'];

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
      _isStreaming = false;
      notifyListeners();
    }
  }

  Future<void> stopResponse() async {
    if (!_isStreaming) return;

    _isStreaming = false;
    isThinking = false;
    notifyListeners();

    try {
      final request = http.Request('POST', Uri.parse('https://maharshi-chat-backend.onrender.com/api/stop'))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({'userId': userId});

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode != 200) {
        print('Failed to stop response generation on the server.');
      }
    } catch (e) {
      print('Error stopping response: $e');
    }
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
