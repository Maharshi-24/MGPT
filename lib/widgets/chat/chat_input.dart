import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart'; // Add this import
import '../../../providers/chat_provider.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool isExpanded = false;
  bool isIconsVisible = true;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Speech-to-text variables
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // Initialize speech-to-text
  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        print("Speech error: $error");
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!available) {
      print("Speech recognition is not available on this device.");
    } else {
      print("Speech recognition initialized successfully.");
    }
  }

  // Start listening to speech
  void _startListening() async {
    // Check and request microphone permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      if (!_isListening) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() {
            _isListening = true;
          });
          _speech.listen(
            onResult: (result) {
              setState(() {
                _recognizedText = result.recognizedWords;
              });
            },
          );
        }
      }
    } else {
      print("Microphone permission denied.");
    }
  }

  // Stop listening to speech
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        // Update the text field with the recognized text
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.textController.text = _recognizedText;
      });
    }
  }

  // Function to pick and resize the image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
      if (image != null) {
        image = img.copyResize(image, width: 100, height: 100);
        final resizedFile = File(pickedFile.path)..writeAsBytesSync(img.encodeJpg(image));
        setState(() {
          _image = resizedFile;
          isExpanded = true;
        });
      }
    }
  }

  // Function to remove the image
  void _removeImage() {
    setState(() {
      _image = null;
      isExpanded = false;
    });
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
                          onPressed: _pickImage,
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
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
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
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    if (_image != null)
                                      Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: FileImage(_image!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: IconButton(
                                              onPressed: _removeImage,
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    TextField(
                                      controller: chatProvider.textController,
                                      focusNode: chatProvider.focusNode,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Message',
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                      enabled: !chatProvider.isThinking,
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
                                  ],
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
                      onPressed: () {
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
            ],
          ),
        ),
        if (_isListening)
          Positioned(
            bottom: 80,
            right: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}