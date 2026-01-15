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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandedAppBar(title: achievement.title, showMascot: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.emoji_events_outlined, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    achievement.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              achievement.description,
              style: const TextStyle(fontSize: 16),
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
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
