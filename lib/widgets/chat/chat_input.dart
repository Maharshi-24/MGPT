import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../providers/chat_provider.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool isExpanded = false;
  bool isIconsVisible = true;
  bool _isListening = false;
  double _soundLevel = 0.0;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  double textFieldHeight = 50.0;

  // Speech-to-text
  stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          setState(() {
            _isListening = false;
            _soundLevel = 0.0;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
        });
      },
    );
  }

  void _startListening() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onError: (error) {
            print("Speech error: $error");
            setState(() {
              _isListening = false;
              _soundLevel = 0.0;
            });
          },
        );

        if (available) {
          setState(() {
            _isListening = true;
          });

          _speech.statusListener = (status) {
            if (status == "notListening" && _isListening) {
              _listenContinuously(); // Restart listening when it stops
            }
          };

          _listenContinuously();
        }
      }
    }
  }

  void _listenContinuously() {
    if (!_isListening) return;

    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          Provider.of<ChatProvider>(context, listen: false).textController.text = _recognizedText;
        });
      },
      onSoundLevelChange: (level) {
        setState(() {
          _soundLevel = level;
        });
      },
      listenFor: Duration(seconds: 30), // Prevents unexpected cutoff
      pauseFor: Duration(seconds: 5), // Allows short pauses
    );
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (!isIconsVisible)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isIconsVisible = true;
                            isExpanded = false;
                          });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  if (isIconsVisible && !isExpanded)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.folder_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.cloud_queue_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = true;
                          isIconsVisible = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        height: textFieldHeight,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: chatProvider.textController,
                                focusNode: chatProvider.focusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Message',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                                enabled: !_isListening,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    isExpanded = true;
                                    isIconsVisible = false;
                                  });
                                },
                                onSubmitted: (value) {
                                  if (!chatProvider.isThinking) {
                                    HapticFeedback.lightImpact();
                                    chatProvider.sendMessage();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                if (_isListening) {
                                  _stopListening();
                                } else {
                                  _startListening();
                                }
                              },
                              icon: Icon(
                                _isListening ? Icons.mic_off : Icons.mic_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: chatProvider.isStreaming ? Colors.white : Colors.white,
                      border: Border.all(
                        color: chatProvider.isStreaming ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _isListening ? null : () { // Disable when listening
                        if (chatProvider.isStreaming) {
                          chatProvider.stopResponse();
                        } else {
                          chatProvider.sendMessage();
                        }
                      },
                      icon: Icon(
                        chatProvider.isStreaming ? Icons.stop : Icons.arrow_upward,
                        color: chatProvider.isStreaming ? Colors.black : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              if (_isListening)
                Center(
                  child: Container(
                    height: 240, // Fixed container height
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100 + _soundLevel * 3,
                      height: 100 + _soundLevel * 3,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 90 + _soundLevel * 3,
                        height: 90 + _soundLevel * 3,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
