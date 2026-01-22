import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const SpeechBubble({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = backgroundColor ?? cs.secondaryContainer;
    final fg = textColor ?? cs.onSecondaryContainer;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: fg,
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
                color: bg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
