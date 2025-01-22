import 'package:flutter/material.dart';

class MessageParser {
  static Widget parse(String text, BuildContext context) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');
    final screenWidth = MediaQuery.of(context).size.width;

    for (var line in lines) {
      if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // Handle headings
      if (line.startsWith('### ')) {
        spans.add(TextSpan(
          text: '${line.substring(4)}\n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('## ')) {
        spans.add(TextSpan(
          text: '${line.substring(3)}\n',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('# ')) {
        spans.add(TextSpan(
          text: '${line.substring(2)}\n',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ));
      }

      // Handle horizontal rules and custom separators
      else if (line.trim().startsWith(RegExp(r'[-=*]{3,}'))) {
        final lineLength = screenWidth * 0.8; // 80% of screen width
        spans.add(TextSpan(
          text: '${'─' * (lineLength ~/ 10.3)}\n', // Adjust length dynamically
          style: const TextStyle(color: Colors.grey),
        ));
      }

      // Handle blockquotes
      else if (line.startsWith('> ')) {
        spans.add(TextSpan(
          text: line.substring(2) + '\n',
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ));
      }

      // Handle lists
      else if (line.startsWith('- ') || line.startsWith('* ') || line.startsWith('+ ')) {
        spans.add(TextSpan(
          text: '• ${line.substring(2)}\n', // Use a bullet point
          style: const TextStyle(fontSize: 16),
        ));
      } else if (line.startsWith(RegExp(r'\d+\. '))) {
        spans.add(TextSpan(
          text: '$line\n',
          style: const TextStyle(fontSize: 16),
        ));
      }

      // Handle inline formatting (bold, italic, strikethrough, underline, code)
      else {
        final regex = RegExp(r'\*\*(.*?)\*\*|__(.*?)__|\*(.*?)\*|_(.*?)_|~~(.*?)~~|\+\+(.*?)\+\+|`(.*?)`');
        final matches = regex.allMatches(line);
        int currentIndex = 0;

        for (var match in matches) {
          if (match.start > currentIndex) {
            spans.add(TextSpan(
              text: line.substring(currentIndex, match.start),
            ));
          }

          final boldText = match.group(1) ?? match.group(2);
          final italicText = match.group(3) ?? match.group(4);
          final strikethroughText = match.group(5);
          final underlineText = match.group(6);
          final codeText = match.group(7);

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
          } else if (strikethroughText != null) {
            spans.add(TextSpan(
              text: strikethroughText,
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ));
          } else if (underlineText != null) {
            spans.add(TextSpan(
              text: underlineText,
              style: const TextStyle(decoration: TextDecoration.underline),
            ));
          } else if (codeText != null) {
            spans.add(TextSpan(
              text: codeText,
              style: TextStyle(fontFamily: 'monospace', backgroundColor: Colors.grey[200]),
            ));
          }

          currentIndex = match.end;
        }

        if (currentIndex < line.length) {
          spans.add(TextSpan(
            text: line.substring(currentIndex),
          ));
        }

        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: spans,
      ),
    );
  }
}