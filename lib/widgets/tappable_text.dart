
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TappableText extends StatelessWidget {
  final String text;
  final Function(String) onWordTap;

  const TappableText({Key? key, required this.text, required this.onWordTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // A professional approach using SelectableText.rich for better performance and text selection
    // We split the text into words but keep punctuations for tap logic
    final List<TextSpan> spans = [];
    
    // Regular expression to identify words while keeping spaces and newlines
    final RegExp wordRegExp = RegExp(r"(\s+|\n|[^\s\n]+)");
    final matches = wordRegExp.allMatches(text);

    for (var match in matches) {
      final part = match.group(0)!;
      
      if (part.trim().isEmpty || part == '\n') {
        // Just add normal text for spaces and newlines
        spans.add(TextSpan(text: part));
      } else {
        // Add tappable span for words
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              height: 1.5,
              // Add a slight background or underline effect on hover/tap if needed
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Remove punctuation like , . ? ! before sending to dictionary
                final cleanWord = part.replaceAll(RegExp(r'[^\u0980-\u09FFa-zA-Z]'), '');
                if (cleanWord.isNotEmpty) {
                  onWordTap(cleanWord);
                }
              },
          ),
        );
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.left,
      cursorColor: Colors.teal,
      showCursor: true,
      toolbarOptions: const ToolbarOptions(
        copy: true,
        selectAll: true,
      ),
    );
  }
}
