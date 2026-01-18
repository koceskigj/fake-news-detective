import 'package:flutter/material.dart';
import 'speech_bubble.dart';

enum StojcheMood { idle, talking, celebrate, wise }

class StojcheHintArea extends StatelessWidget {
  final StojcheMood mood;
  final bool hintUsed;
  final String? hintText;
  final VoidCallback onAsk;

  const StojcheHintArea({
    super.key,
    required this.mood,
    required this.hintUsed,
    required this.hintText,
    required this.onAsk,
  });

  IconData _iconForMood(StojcheMood mood) {
    switch (mood) {
      case StojcheMood.talking:
        return Icons.record_voice_over_outlined;
      case StojcheMood.celebrate:
        return Icons.celebration_outlined;
      case StojcheMood.wise:
        return Icons.psychology_outlined;
      case StojcheMood.idle:
      default:
        return Icons.emoji_nature;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Opacity(
          opacity: 0.35,
          child: Container(
            width: 78,
            height: 92,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _iconForMood(mood),
              size: 44,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: hintText == null
              ? Align(
            alignment: Alignment.bottomLeft,
            child: FilledButton.tonalIcon(
              onPressed: hintUsed ? null : onAsk,
              icon: const Icon(Icons.question_answer_outlined),
              label: const Text('Ask Stojche'),
            ),
          )
              : SpeechBubble(text: hintText!),
        ),
      ],
    );
  }
}
