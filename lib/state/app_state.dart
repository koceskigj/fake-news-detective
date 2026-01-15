import 'package:flutter/foundation.dart';
import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../models/celebration_event.dart';
import '../models/user_progress.dart';

class AppState {
  final UserProgress progress;

  int _sessionStreak = 0;

  // ✅ Shown after the first case solved that day
  CelebrationEvent? _pendingDailyStreakEvent;

  AppState({required this.progress});

  int get sessionStreak => _sessionStreak;

  int targetDifficultyFromStreak() {
    if (_sessionStreak >= 5) return 3;
    if (_sessionStreak >= 3) return 2;
    return 1;
  }

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

  String _dateKey(DateTime dt) {
    // local date key: YYYY-MM-DD
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
  }

  int _daysBetweenDateOnly(DateTime a, DateTime b) {
    // Compare by calendar days (local timezone)
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  /// Call on app start/resume (not at midnight).
  /// Updates daily streak based on local calendar day.
  void onAppResumed({DateTime? now}) {
    final t = now ?? DateTime.now();

    final last = progress.lastOpenDate;
    progress.lastOpenDate = t;

    // First ever open: start streak at 1 but don't spam celebration
    if (last == null) {
      if (progress.dailyStreak == 0) progress.dailyStreak = 1;
      return;
    }

    // Same calendar day => no change
    if (_dateKey(last) == _dateKey(t)) return;

    final diffDays = _daysBetweenDateOnly(last, t);

    if (diffDays == 1) {
      progress.dailyStreak += 1;
    } else if (diffDays > 1) {
      // missed at least one day
      progress.dailyStreak = 1;
    } else {
      // time travel / clock change; ignore
      return;
    }

    // Queue streak celebration to show after first case solve
    _pendingDailyStreakEvent =
        CelebrationEvent.dailyStreakUpdated(progress.dailyStreak);

    if (kDebugMode) {
      debugPrint('Daily streak updated -> ${progress.dailyStreak}');
    }
  }

  /// Returns celebration events unlocked by this action.
  List<CelebrationEvent> recordCaseSolved({
    required String caseId,
    required bool isCorrect,
    required int difficulty,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();

    final events = <CelebrationEvent>[];
    final oldLevel = progress.level;

    // Count case only once
    final wasNew = progress.solvedCaseIds.add(caseId);
    if (wasNew) {
      progress.casesSolvedTotal += 1;
    }

    if (isCorrect) {
      progress.correctAnswersTotal += 1;

      _sessionStreak += 1;
      if (_sessionStreak > progress.bestPerfectStreak) {
        progress.bestPerfectStreak = _sessionStreak;
      }

      progress.awardXp(xpForDifficulty(difficulty));
    } else {
      _sessionStreak = 0;
    }

    // Achievements can add XP
    final unlockedAchievementIds = _evaluateAndUnlockAchievements(t);
    for (final id in unlockedAchievementIds) {
      events.add(CelebrationEvent.achievementUnlocked(id));
    }

    // Level up check (after all XP changes)
    final newLevel = progress.level;
    if (newLevel > oldLevel) {
      events.add(CelebrationEvent.levelUp(oldLevel, newLevel));
    }

    // ✅ Inject daily streak celebration (after the first case solved that day)
    if (_pendingDailyStreakEvent != null) {
      events.insert(0, _pendingDailyStreakEvent!); // show it first
      _pendingDailyStreakEvent = null;
    }

    return events;
  }

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

  List<String> _evaluateAndUnlockAchievements(DateTime now) {
    final unlocked = <String>[];

    for (final a in achievementsCatalog) {
      if (progress.isAchievementUnlocked(a.id)) continue;

      final current = _valueForCriteria(a.criteria);
      if (current >= a.criteria.threshold) {
        progress.unlockAchievement(a.id, now);
        progress.awardXp(a.xpReward);
        unlocked.add(a.id);

        if (kDebugMode) {
          debugPrint('Unlocked achievement: ${a.id} (+${a.xpReward} XP)');
        }
      }
    }

    return unlocked;
  }
}
