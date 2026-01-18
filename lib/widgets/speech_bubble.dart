import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;

  const SpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: cs.onSecondaryContainer,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned(
          left: -10,
          bottom: 14,
          child: Transform.rotate(
            angle: 0.6,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
