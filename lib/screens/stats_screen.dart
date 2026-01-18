import 'package:flutter/material.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _pct(int part, int total) {
    if (total <= 0) return '0%';
    final p = (part / total) * 100.0;
    return '${p.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final p = appState.progress;

    final solved = p.casesSolvedTotal;
    final correct = p.correctAnswersTotal;
    final accuracy = _pct(correct, solved);

    return Scaffold(
      appBar: const BrandedAppBar(showDailyStreak: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          _StatCard(
            title: 'Performance',
            rows: [
              _StatRow('Cases solved', '$solved'),
              _StatRow('Correct answers', '$correct'),
              _StatRow('All-time accuracy', accuracy),
            ],
          ),

          const SizedBox(height: 12),

          _StatCard(
            title: 'Progress',
            rows: [
              _StatRow('Total XP', '${p.xp}'),
              _StatRow('Level', '${p.level}'),
              _StatRow('Achievements earned', '${p.unlockedAchievementIds.length}'),
            ],
          ),

          const SizedBox(height: 12),

          _StatCard(
            title: 'Streak Records',
            rows: [
              _StatRow('Best daily streak', '${p.bestDailyStreak} day(s)'),
              _StatRow('Best correct streak', '${p.bestPerfectStreak}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final List<_StatRow> rows;

  const _StatCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(r.value),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatRow {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);
}
