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

  String _assetForMood(StojcheMood mood) {
    switch (mood) {
      case StojcheMood.talking:
        return 'assets/stojche/stojche_talking.png';
      case StojcheMood.celebrate:
        return 'assets/stojche/stojche_correct.png';
      case StojcheMood.wise:
        return 'assets/stojche/stojche_wrong.png';
      case StojcheMood.idle:
      default:
        return 'assets/stojche/stojche_idle.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Stojche (bigger, recognizable) ---
        SizedBox(
          width: 175,
          height: 200,
          child: Image.asset(
            _assetForMood(mood),
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 12),

        // --- Right side: button or speech bubble ---
        Expanded(
          child: hintText == null
              ? Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: hintUsed ? null : onAsk,
              icon: const Icon(Icons.question_answer_outlined),
              label: const Text('Ask Stojche'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          )
              : SpeechBubble(
            text: hintText!,
            backgroundColor: cs.secondaryContainer,
            textColor: cs.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}
