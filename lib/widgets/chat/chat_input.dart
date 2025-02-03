import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img; // Keep this import
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
  File? _file; // For file picking
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
      pauseFor: Duration(seconds: 5), // Allows short pauses
      listenMode: stt.ListenMode.dictation, // Ensure it listens continuously
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

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Function to pick a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  // Function to remove the selected image
  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  // Function to remove the selected file
  void _removeFile() {
    setState(() {
      _file = null;
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
                          HapticFeedback.lightImpact(); // Added haptic feedback on icon button press
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
                          onPressed: () {
                            _pickImage(); // Pick image when image icon is tapped
                            HapticFeedback.lightImpact(); // Haptic feedback on image icon press
                          },
                          icon: const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _pickFile(); // Pick file when folder icon is tapped
                            HapticFeedback.lightImpact(); // Haptic feedback on folder icon press
                          },
                          icon: const Icon(
                            Icons.folder_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Cloud actions can be added here
                            HapticFeedback.lightImpact(); // Haptic feedback on cloud icon press
                          },
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
                        HapticFeedback.selectionClick(); // Haptic feedback on text field tap
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
                                  HapticFeedback.selectionClick(); // Added haptic feedback for text field tap
                                  setState(() {
                                    isExpanded = true;
                                    isIconsVisible = false;
                                  });
                                },
                                onSubmitted: (value) {
                                  if (!chatProvider.isThinking) {
                                    HapticFeedback.lightImpact(); // Haptic feedback when submitting message
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
                                  HapticFeedback.lightImpact(); // Haptic feedback on stop listening
                                } else {
                                  _startListening();
                                  HapticFeedback.lightImpact(); // Haptic feedback on start listening
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
                          HapticFeedback.lightImpact(); // Haptic feedback on stop response
                        } else {
                          chatProvider.sendMessage();
                          HapticFeedback.lightImpact(); // Haptic feedback on send message
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

              if (_image != null) // Show image thumbnail with cross button
                Stack(
                  children: [
                    Image.file(
                      _image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: _removeImage, // Remove image
                      ),
                    ),
                  ],
                ),

              if (_file != null) // Show file name with cross button
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey[700],
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _file!.path.split('/').last,
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: _removeFile, // Remove file
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
