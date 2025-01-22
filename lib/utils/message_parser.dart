import 'package:flutter/material.dart';

class MessageParser {
  static Widget parse(String text) {
    final regex = RegExp(r'\*\*(.*?)\*\*|__(.*?)__|\*(.*?)\*|_(.*?)_');
    final matches = regex.allMatches(text);
    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
        ));
      }

      final boldText = match.group(1) ?? match.group(2);
      final italicText = match.group(3) ?? match.group(4);

      if (boldText != null) {
        spans.add(TextSpan(
          text: boldText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (italicText != null) {
        spans.add(TextSpan(
          text: italicText,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
      ));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: spans,
      ),
    );
  }
}