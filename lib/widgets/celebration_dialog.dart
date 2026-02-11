import 'package:flutter/material.dart';


import '../data/achievements_catalog.dart';
import '../l10n/app_localizations.dart';
import '../models/celebration_event.dart';

class CelebrationDialog extends StatelessWidget {
  final CelebrationEvent event;

  const CelebrationDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
      headerText = l10n.celebrationLevelUpTitle;
      line2 = l10n.celebrationNowLevel(event.newLevel!);
      mainImageAsset = levelUpAsset;
    } else if (isDaily) {
      headerText = l10n.celebrationDailyStreakTitle;
      line2 = l10n.celebrationDailyStreakLine(event.newDailyStreak!);

      mainImageAsset = dailyStreakAsset;
    } else {
      final ach = achievementsCatalog.firstWhere(
            (a) => a.id == event.achievementId,
        orElse: () => achievementsCatalog.first,
      );

      headerText = l10n.celebrationAchievementUnlockedTitle;
      line2 = l10n.celebrationUnlockedAchievement(ach.title);
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
                Text(
                  l10n.celebrationCongratsDetective,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
                  child: Text(l10n.continueBtn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
