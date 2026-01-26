import 'package:flutter/material.dart';
import '../data/achievements_catalog.dart';
import '../models/celebration_event.dart';

class CelebrationDialog extends StatelessWidget {
  final CelebrationEvent event;

  const CelebrationDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bool isAchievement =
        event.type == CelebrationEventType.achievementUnlocked;
    final bool isLevelUp = event.type == CelebrationEventType.levelUp;
    final bool isDaily = event.type == CelebrationEventType.dailyStreakUpdated;

    String headerText;
    String line2;
    String? mainImageAsset;

    const levelUpAsset = 'assets/achievements/leveling_up.png';
    const dailyStreakAsset = 'assets/achievements/leveling_up.png';

    if (isLevelUp) {
      headerText = 'Level Up!';
      line2 = 'You are now Level ${event.newLevel} 🎉';
      mainImageAsset = levelUpAsset;
    } else if (isDaily) {
      headerText = 'Daily Streak!';
      line2 = 'Streak continued: ${event.newDailyStreak} day(s) 📅';
      mainImageAsset = dailyStreakAsset;
    } else {
      // Achievement unlocked
      final ach = achievementsCatalog.firstWhere(
            (a) => a.id == event.achievementId,
        orElse: () => achievementsCatalog.first,
      );

      headerText = 'Achievement Unlocked!';
      line2 = 'You unlocked "${ach.title}"';
      mainImageAsset = 'assets/achievements/${ach.iconKey}.png';
    }

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: cs.surface,

          titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          actionsPadding: const EdgeInsets.fromLTRB(18, 12, 18, 16),

          title: Text(
            headerText,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),

          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Main image for all event types
                if (mainImageAsset != null) ...[
                  Center(
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.asset(
                        mainImageAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          isAchievement
                              ? Icons.emoji_events_outlined
                              : isLevelUp
                              ? Icons.bolt
                              : Icons.calendar_month_outlined,
                          size: 72,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Text(
                  'Congratulations detective!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  line2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
