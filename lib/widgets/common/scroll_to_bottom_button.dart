import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScrollToBottomButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // Light vibration
          onPressed();
        },
        borderRadius: BorderRadius.circular(25), // Matches circular shape
        child: ClipOval(
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
              child: Image.asset(
                'assets/images/scroll-to-bottom.png',
                width: 20,
                height: 20,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
