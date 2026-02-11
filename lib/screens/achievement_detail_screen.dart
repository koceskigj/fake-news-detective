import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart'; // if you use flutter_gen, update import in your project
import '../l10n/l10n_ext.dart';
import '../models/achievement.dart';
import '../widgets/branded_app_bar.dart';

class AchievementDetailScreen extends StatelessWidget {
  final Achievement achievement;
  final DateTime unlockedAt;

  const AchievementDetailScreen({
    super.key,
    required this.achievement,
    required this.unlockedAt,
  });

  String _fmtDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
  }

  String get _assetPath => 'assets/achievements/${achievement.iconKey}.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final titleText = l10n.byKey(achievement.title);
    final descText = l10n.byKey(achievement.description);

    return Scaffold(
      appBar: const BrandedAppBar(showDailyStreak: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            titleText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            descText,
            style: const TextStyle(fontSize: 16, height: 1.3),
          ),
          const SizedBox(height: 14),

          Center(
            child: SizedBox(
              width: 360,
              height: 360,
              child: Image.asset(
                _assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) {
                  return const Center(
                    child: Icon(Icons.emoji_events_outlined, size: 80),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(l10n.achievementUnlockedOn),
              subtitle: Text(_fmtDate(unlockedAt)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bolt),
              title: Text(l10n.achievementXpReward),
              subtitle: Text(l10n.achievementXpValue(achievement.xpReward)),
            ),
          ),
        ],
      ),
    );
  }
}
