import 'package:flutter/material.dart';

class ThinkingIndicator extends StatefulWidget {
  final Duration animationDuration; // Add a parameter for animation speed

  const ThinkingIndicator({super.key, this.animationDuration = const Duration(milliseconds: 1200)});

  @override
  _ThinkingIndicatorState createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with the provided duration
    _controller = AnimationController(
      duration: widget.animationDuration, // Use the configurable duration
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely

    // Create animations for each dot
    _dotAnimations = List.generate(3, (index) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50), // Grow
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50), // Shrink
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2, // Stagger the animations for each dot
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // Align to the left side
      child: Container(
        margin: const EdgeInsets.only(left: 16), // Add left margin
        padding: const EdgeInsets.all(12), // Padding around the dots
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Use minimum width
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _dotAnimations[index].value, // Scale the dot
                  child: Container(
                    width: 16, // Dot width
                    height: 16, // Dot height
                    margin: const EdgeInsets.symmetric(horizontal: 4), // Spacing between dots
                    decoration: const BoxDecoration(
                      color: Colors.white, // White dots
                      shape: BoxShape.circle, // Circular dots
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}