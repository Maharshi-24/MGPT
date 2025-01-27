import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _controller;
  final List<Color> _backgroundColors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.teal,
    Colors.blueGrey,
    Colors.deepOrange,
  ];
  final List<Color> _textColors = [
    Colors.white,
    Colors.amberAccent,
    Colors.lightGreenAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];
  int _currentColorIndex = 0;

  final List<String> _streamTexts = [
    'Start something new...',
    'Explore the possibilities...',
    'Unlock your potential...',
    'Let’s create something amazing...',
    'Innovate and inspire...',
  ];
  int _currentTextIndex = 0;
  String _displayText = '';
  int _currentLetterIndex = 0;
  bool _isTyping = true;

  // Animation speed (milliseconds per letter)
  final int _typingSpeed = 100; // Adjust this value to control typing speed
  final int _deletingSpeed = 50; // Adjust this value to control deleting speed

  // Padding for the text and circle
  final EdgeInsets _textPadding = const EdgeInsets.only(right: 16); // Adjust this value

  // Position of the text and button
  final Alignment _textPosition = Alignment(0.0, -0.31); // Adjust this value
  final Alignment _buttonPosition = Alignment(0.0, 1); // Adjust this value (lifted up)

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Start text stream
    _startTextStream();
  }

  void _startTextStream() {
    Future.delayed(Duration(milliseconds: _isTyping ? _typingSpeed : _deletingSpeed), () {
      if (mounted) {
        if (_isTyping) {
          // Typing animation: Add one letter at a time
          if (_currentLetterIndex < _streamTexts[_currentTextIndex].length) {
            setState(() {
              _displayText += _streamTexts[_currentTextIndex][_currentLetterIndex];
              _currentLetterIndex++;
            });
            _startTextStream();
          } else {
            // Wait for a moment before starting to delete
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isTyping = false;
                });
                _startTextStream();
              }
            });
          }
        } else {
          // Deleting animation: Remove one letter at a time
          if (_displayText.isNotEmpty) {
            setState(() {
              _displayText = _displayText.substring(0, _displayText.length - 1);
            });
            _startTextStream();
          } else {
            // Move to the next text and cycle colors
            setState(() {
              _currentTextIndex = (_currentTextIndex + 1) % _streamTexts.length;
              _currentLetterIndex = 0;
              _isTyping = true;
              _currentColorIndex = (_currentColorIndex + 1) % _backgroundColors.length;
            });
            _startTextStream();
          }
        }
      }
    });
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('Signup successful!');
        HapticFeedback.lightImpact(); // Haptic feedback on successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        print('Signup failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Signup failed')),
        );
        HapticFeedback.heavyImpact(); // Haptic feedback on sign-up failure
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _backgroundColors[_currentColorIndex],
                      _backgroundColors[_currentColorIndex].withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // Center of y: Text Stream and Circle
          Align(
            alignment: _textPosition, // Use the position you control
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text Stream
                Padding(
                  padding: _textPadding, // Use the padding you control
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      _displayText,
                      key: ValueKey<String>(_displayText),
                      style: TextStyle(
                        color: _textColors[_currentColorIndex], // Cycle text colors
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Circle (same color as text)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _textColors[_currentColorIndex], // Match text color
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Signup Container (lifted up)
          Align(
            alignment: _buttonPosition, // Use the position you control
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide( // Add a border
                              color: Colors.grey, // Border color
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact(); // Haptic feedback when navigating to login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}