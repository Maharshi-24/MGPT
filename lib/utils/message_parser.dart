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

      if (line.trim().startsWith(RegExp(r'[-=*]{3,}'))) {
        final lineLength = screenWidth * 0.8;
        spans.add(TextSpan(
          text: '${'─' * (lineLength ~/ 10.3)}\n',
          style: const TextStyle(color: Colors.grey, fontFamily: 'VT323'),
        ));
      } else if (line.startsWith('### ')) {
        spans.add(TextSpan(
          text: '${line.substring(4)}\n',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'VT323'),
        ));
      } else if (line.startsWith('## ')) {
        spans.add(TextSpan(
          text: '${line.substring(3)}\n',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'VT323'),
        ));
      } else if (line.startsWith('# ')) {
        spans.add(TextSpan(
          text: '${line.substring(2)}\n',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'VT323'),
        ));
      } else if (line.startsWith('> ')) {
        spans.add(TextSpan(
          text: line.substring(2) + '\n',
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontFamily: 'VT323'),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ') || line.startsWith('+ ')) {
        spans.add(TextSpan(
          text: '• ${line.substring(2)}\n',
          style: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'VT323'),
        ));
      } else if (line.startsWith(RegExp(r'\d+\. '))) {
        spans.add(TextSpan(
          text: '$line\n',
          style: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'VT323'),
        ));
      } else {
        final regex = RegExp(r'\*\*(.*?)\*\*|__(.*?)__|\*(.*?)\*|_(.*?)_|~~(.*?)~~|\+\+(.*?)\+\+|`(.*?)`');
        final matches = regex.allMatches(line);
        int currentIndex = 0;

        for (var match in matches) {
          if (match.start > currentIndex) {
            spans.add(TextSpan(
              text: line.substring(currentIndex, match.start),
              style: const TextStyle(color: Colors.white, fontFamily: 'VT323'),
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'VT323'),
            ));
          } else if (italicText != null) {
            spans.add(TextSpan(
              text: italicText,
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white, fontFamily: 'VT323'),
            ));
          } else if (strikethroughText != null) {
            spans.add(TextSpan(
              text: strikethroughText,
              style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.white, fontFamily: 'VT323'),
            ));
          } else if (underlineText != null) {
            spans.add(TextSpan(
              text: underlineText,
              style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white, fontFamily: 'VT323'),
            ));
          } else if (codeText != null) {
            spans.add(TextSpan(
              text: codeText,
              style: TextStyle(fontFamily: 'monospace', backgroundColor: Colors.grey[700], color: Colors.white),
            ));
          }

          currentIndex = match.end;
        }

        if (currentIndex < line.length) {
          spans.add(TextSpan(
            text: line.substring(currentIndex),
            style: const TextStyle(color: Colors.white, fontFamily: 'VT323'),
          ));
        }

        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'VT323'),
        children: spans,
      ),
    );
  }
}
