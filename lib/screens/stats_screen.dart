import 'package:flutter/material.dart';


import '../l10n/app_localizations.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _pct(int part, int total, AppLocalizations l10n) {
    if (total <= 0) return l10n.pctZero; // "0%"
    final p = (part / total) * 100.0;
    return '${p.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final appState = AppStateScope.of(context);
    final p = appState.progress;

    final solved = p.casesSolvedTotal;
    final correct = p.correctAnswersTotal;
    final accuracy = _pct(correct, solved, l10n);

    return Scaffold(
      appBar: BrandedAppBar(
        showDailyStreak: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _StatCard(
            title: l10n.statsPerformanceTitle,
            rows: [
              _StatRow(l10n.statsCasesSolved, '$solved'),
              _StatRow(l10n.statsCorrectAnswers, '$correct'),
              _StatRow(l10n.statsAllTimeAccuracy, accuracy),
            ],
          ),

          const SizedBox(height: 12),

          _StatCard(
            title: l10n.statsProgressTitle,
            rows: [
              _StatRow(l10n.statsTotalXp, '${p.xp}'),
              _StatRow(l10n.level, '${p.level}'),
              _StatRow(l10n.statsAchievementsEarned, '${p.unlockedAchievementIds.length}'),
            ],
          ),

          const SizedBox(height: 12),

          _StatCard(
            title: l10n.statsStreakRecordsTitle,
            rows: [
              _StatRow(l10n.statsBestDailyStreak, l10n.dayCount(p.bestDailyStreak)),
              _StatRow(l10n.statsBestCorrectStreak, '${p.bestPerfectStreak}'),
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
            ...rows.map(
                  (r) => Padding(
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
              ),
            ),
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
