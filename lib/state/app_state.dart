import 'package:flutter/foundation.dart';
import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';

class AppState {
  final UserProgress progress;

  /// Session-only streak (consecutive correct answers without a wrong answer)
  int _currentPerfectStreak = 0;

  AppState({required this.progress});

  /// Call this when a user answers a case.
  /// - Marks the case as solved (once)
  /// - Updates counters
  /// - Updates perfect streak
  /// - Evaluates achievements and awards XP
  void recordCaseSolved({
    required String caseId,
    required bool isCorrect,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();

    // Only count a case once
    final wasNew = progress.solvedCaseIds.add(caseId);
    if (wasNew) {
      progress.casesSolvedTotal += 1;
    }

    if (isCorrect) {
      progress.correctAnswersTotal += 1;
      _currentPerfectStreak += 1;
      if (_currentPerfectStreak > progress.bestPerfectStreak) {
        progress.bestPerfectStreak = _currentPerfectStreak;
      }
      // Base reward for correct answer
      progress.awardXp(10);
    } else {
      // Reset streak on wrong answer
      _currentPerfectStreak = 0;
      // Small penalty is optional; keep it friendly
      // progress.awardXp(-2);
    }

    // Achievements may unlock as a result
    _evaluateAndUnlockAchievements(t);
  }

  /// Manual XP add (useful for testing or future features)
  void addXp(int amount, {DateTime? now}) {
    progress.awardXp(amount);
    _evaluateAndUnlockAchievements(now ?? DateTime.now());
  }

  /// If you later implement daily streak logic, call this on app open.
  void recordAppOpened({DateTime? now}) {
    final t = now ?? DateTime.now();
    // Placeholder: daily streak rules will be implemented later.
    progress.lastOpenDate = t;
    _evaluateAndUnlockAchievements(t);
  }

  int _valueForCriteria(AchievementCriteria c) {
    switch (c.type) {
      case AchievementType.casesSolvedTotal:
        return progress.casesSolvedTotal;
      case AchievementType.correctAnswersTotal:
        return progress.correctAnswersTotal;
      case AchievementType.perfectStreak:
        return progress.bestPerfectStreak;
      case AchievementType.dailyStreakDays:
        return progress.dailyStreak;
      case AchievementType.xpTotal:
        return progress.xp;
    }
  }

  void _evaluateAndUnlockAchievements(DateTime now) {
    for (final a in achievementsCatalog) {
      if (progress.isAchievementUnlocked(a.id)) continue;

      final current = _valueForCriteria(a.criteria);
      if (current >= a.criteria.threshold) {
        progress.unlockAchievement(a.id, now);
        progress.awardXp(a.xpReward);

        if (kDebugMode) {
          debugPrint('Unlocked achievement: ${a.id} (+${a.xpReward} XP)');
        }
      }
    }
  }
}
