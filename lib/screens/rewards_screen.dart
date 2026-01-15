
import 'package:flutter/material.dart';

import '../data/achievements_catalog.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';
import 'achievement_detail_screen.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String _fmtDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final progress = appState.progress;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'Rewards'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.bolt),
                title: Text('Level ${progress.level}'),
                subtitle: Text('XP: ${progress.xp}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leaderboard will be added later ✅')),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                itemCount: achievementsCatalog.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, i) {
                  final a = achievementsCatalog[i];
                  final unlocked = progress.isAchievementUnlocked(a.id);

                  // ✅ FIX: define unlockedAt here so it can be used in UI + onTap
                  final unlockedAt = progress.achievementUnlockedAt[a.id];

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (!unlocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not unlocked yet 🔒')),
                        );
                        return;
                      }

                      if (unlockedAt == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unlocked date missing (debug)')),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AchievementDetailScreen(
                            achievement: a,
                            unlockedAt: unlockedAt,
                          ),
                        ),
                      );
                    },
                    child: Opacity(
                      opacity: unlocked ? 1.0 : 0.45,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(unlocked ? Icons.emoji_events_outlined : Icons.lock_outline),
                              const SizedBox(height: 8),
                              Text(
                                a.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (unlocked && unlockedAt != null)
                                Text(
                                  _fmtDate(unlockedAt),
                                  style: const TextStyle(fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
