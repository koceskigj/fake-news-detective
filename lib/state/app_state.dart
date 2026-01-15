import 'package:flutter/foundation.dart';
import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';

class AppState {
  final UserProgress progress;

  /// Consecutive correct answers in THIS session (used for adaptive difficulty)
  int _sessionStreak = 0;

  AppState({required this.progress});

  int get sessionStreak => _sessionStreak;

  /// Target difficulty based on streak.
  /// 0-2 => easy(1), 3-4 => medium(2), 5+ => hard(3)
  int targetDifficultyFromStreak() {
    if (_sessionStreak >= 5) return 3;
    if (_sessionStreak >= 3) return 2;
    return 1;
  }

  /// XP per difficulty
  int xpForDifficulty(int difficulty) {
    switch (difficulty) {
      case 3:
        return 20;
      case 2:
        return 15;
      default:
        return 10;
    }
  }

  /// Call when a user answers a case.
  /// - updates solved/correct counters
  /// - updates streak (session)
  /// - awards XP based on difficulty (only if correct)
  /// - unlocks achievements (and awards achievement XP)
  void recordCaseSolved({
    required String caseId,
    required bool isCorrect,
    required int difficulty,
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

      // Update streaks
      _sessionStreak += 1;
      if (_sessionStreak > progress.bestPerfectStreak) {
        progress.bestPerfectStreak = _sessionStreak;
      }

      // XP reward scaled by difficulty
      progress.awardXp(xpForDifficulty(difficulty));
    } else {
      // Wrong answer resets streak and "drops" challenge naturally
      _sessionStreak = 0;
    }

    _evaluateAndUnlockAchievements(t);
  }

  /// Manual XP add (still useful later)
  void addXp(int amount, {DateTime? now}) {
    progress.awardXp(amount);
    _evaluateAndUnlockAchievements(now ?? DateTime.now());
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
