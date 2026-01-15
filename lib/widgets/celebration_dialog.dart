import 'package:flutter/material.dart';
import '../models/celebration_event.dart';
import '../data/achievements_catalog.dart';

class CelebrationDialog extends StatelessWidget {
  final CelebrationEvent event;

  const CelebrationDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String title;
    String subtitle;
    IconData rightIcon;

    switch (event.type) {
      case CelebrationEventType.levelUp:
        title = 'Level Up!';
        subtitle = 'You are now Level ${event.newLevel} 🎉';
        rightIcon = Icons.bolt;
        break;

      case CelebrationEventType.dailyStreakUpdated:
        title = 'Daily Streak!';
        subtitle = 'You’ve kept your streak: ${event.newDailyStreak} day(s) 🔥';
        rightIcon = Icons.local_fire_department_outlined;
        break;

      case CelebrationEventType.achievementUnlocked:
      default:
        final ach = achievementsCatalog.firstWhere(
              (a) => a.id == event.achievementId,
          orElse: () => achievementsCatalog.first,
        );
        title = 'Achievement Unlocked!';
        subtitle = 'Congratulations! You unlocked "${ach.title}"';
        rightIcon = Icons.emoji_events_outlined;
        break;
    }

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1.0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: cs.surface,
          titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          actionsPadding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Row(
            children: [
              // Mascot placeholder (Stojche)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.emoji_nature,
                  size: 34,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subtitle, style: const TextStyle(height: 1.25)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(rightIcon, size: 18, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Nice work, detective!',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
