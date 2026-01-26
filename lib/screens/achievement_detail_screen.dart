import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: BrandedAppBar(showDailyStreak: true, extraActions: const []),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            achievement.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.description,
            style: const TextStyle(fontSize: 16, height: 1.3),
          ),
          const SizedBox(height: 14),

          // ✅ Badge image under the description
          Center(
            child: SizedBox(
              width: 360,
              height: 360,
              child: Image.asset(
                _assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) {
                  // Fallback if image missing
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
              title: const Text('Unlocked on'),
              subtitle: Text(_fmtDate(unlockedAt)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bolt),
              title: const Text('XP reward'),
              subtitle: Text('${achievement.xpReward} XP'),
            ),
          ),
        ],
      ),
    );
  }
}
