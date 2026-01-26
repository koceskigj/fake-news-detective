import 'package:flutter/material.dart';
import '../data/achievements_catalog.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';
import 'achievement_detail_screen.dart';
import 'leaderboard_screen.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final progress = appState.progress;

    // Blue-ish for unlocked
    const unlockedBg = Color(0xFFE8F0FE); // soft blue
    const unlockedFg = Color(0xFF174EA6); // deep blue

    // Grey for locked
    const lockedBg = Color(0xFFF2F2F2);
    const lockedFg = Color(0xFF6B6B6B);

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level card -> Leaderboard
            Card(
              child: ListTile(
                leading: const Icon(Icons.bolt),
                title: Text('Level ${progress.level}'),
                subtitle: Text('XP: ${progress.xp}'),
                trailing: const Icon(Icons.leaderboard_outlined),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                  );
                  if (!mounted) return;
                  setState(() {}); // refresh after returning
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                  final unlockedAt = progress.achievementUnlockedAt[a.id];

                  final bg = unlocked ? unlockedBg : lockedBg;
                  final fg = unlocked ? unlockedFg : lockedFg;

                  final badgePath = 'assets/achievements/${a.iconKey}.png';

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
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

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AchievementDetailScreen(
                            achievement: a,
                            unlockedAt: unlockedAt,
                          ),
                        ),
                      );

                      if (!mounted) return;
                      setState(() {});
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        color: bg,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (unlocked)
                              SizedBox(
                                width: 46,
                                height: 46,
                                child: Image.asset(
                                  badgePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.emoji_events_outlined, color: fg),
                                ),
                              )
                            else
                              Icon(Icons.lock_outline, color: fg),

                            const SizedBox(height: 8),

                            Text(
                              a.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: fg,
                              ),
                            ),
                          ],
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
