import 'package:flutter/material.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScrollToBottomButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _buildImageIcon(),
        ),
      ),
    );
  }

  Widget _buildImageIcon() {
    try {
      return Image.asset(
        'assets/images/scroll-to-bottom.png',
        width: 20,
        height: 20,
        color: Colors.white,
      );
    } catch (e) {
      print('Error loading image: $e');
      return const Icon(Icons.error);
    }
  }
}