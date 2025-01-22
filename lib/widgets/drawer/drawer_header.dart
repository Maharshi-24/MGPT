import 'package:flutter/material.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      color: const Color(0xFF0C0C0C),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}