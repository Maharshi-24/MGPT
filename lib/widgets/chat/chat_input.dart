import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:image/image.dart' as img; // For resizing the image
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool isExpanded = false; // To track if the text field is expanded
  bool isIconsVisible = true; // To track if the icons are visible
  File? _image; // Store the selected image
  final ImagePicker _picker = ImagePicker();

  // Function to pick and resize the image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Load the image as a byte array
      final bytes = await pickedFile.readAsBytes();

      // Decode the image and resize it
      img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

      // Resize the image to 100px by 100px
      if (image != null) {
        image = img.copyResize(image, width: 100, height: 100); // Resize to 100px by 100px
        final resizedFile = File(pickedFile.path)..writeAsBytesSync(img.encodeJpg(image));

        // Set the resized image to display
        setState(() {
          _image = resizedFile;
          isExpanded = true; // Expand the text field to fit the image
        });
      }
    }
  }

  // Function to remove the image
  void _removeImage() {
    setState(() {
      _image = null;
      isExpanded = false; // Collapse text field when the image is removed
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Container(
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
              // Show the plus button when icons are hidden
              if (!isIconsVisible)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey, // Set background color to grey
                    shape: BoxShape.circle, // To keep the plus button circular
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isIconsVisible = true; // Restore icons when plus button is tapped
                        isExpanded = false; // Collapse the text field
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Show icons when they are visible and text field is not expanded
              if (isIconsVisible && !isExpanded)
                Row(
                  mainAxisSize: MainAxisSize.min, // Reduce the space between icons
                  children: [
                    IconButton(
                      onPressed: _pickImage,  // Pick image on icon press
                      icon: const Icon(
                        Icons.image_outlined,
                        color: Colors.white,
                        size: 25, // Reduce the size of the icon
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.folder_outlined,
                        color: Colors.white,
                        size: 25, // Reduce the size of the icon
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.cloud_queue_outlined,
                        color: Colors.white,
                        size: 25, // Reduce the size of the icon
                      ),
                    ),
                  ],
                ),

              const SizedBox(width: 8),

              // Smooth Animated Expansion for Text Field
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: GestureDetector(
                    onTap: () {
                      // When the text field is tapped, expand it and hide the icons
                      setState(() {
                        isExpanded = true;
                        isIconsVisible = false; // Hide icons and show plus button
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
                                // Show the image inside the text input area if selected
                                if (_image != null)
                                  Stack(
                                    children: [
                                      // Display the resized image in the text input area
                                      Container(
                                        width: double.infinity,
                                        height: 100, // Fixed height for the resized image
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: FileImage(_image!),
                                            fit: BoxFit.cover, // Fit the image to cover the width
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: IconButton(
                                          onPressed: _removeImage,  // Remove image on cross press
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                // TextField below the image (if image is present)
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
                                    HapticFeedback.selectionClick(); // Light vibration for text field tap
                                    setState(() {
                                      isExpanded = true;
                                      isIconsVisible = false; // Hide icons and show plus button
                                    });
                                  },
                                  onSubmitted: (value) {
                                    if (!chatProvider.isThinking) {
                                      HapticFeedback.lightImpact(); // Light vibration for submission
                                      chatProvider.sendMessage();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Mic icon remains at the starting point of the text input area
                          const Icon(Icons.mic_outlined, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send/Stop Button
              Container(
                decoration: BoxDecoration(
                  color: chatProvider.isStreaming ? Colors.white : Colors.white,
                  border: Border.all(
                    color: chatProvider.isStreaming ? Colors.black : Colors.transparent, // Black border for Stop
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  onPressed: () {
                    if (chatProvider.isStreaming) {
                      chatProvider.stopResponse(); // Trigger stop
                    } else {
                      chatProvider.sendMessage(); // Trigger send
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
    );
  }
}
