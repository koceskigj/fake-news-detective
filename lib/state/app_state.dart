import 'package:flutter/foundation.dart';
import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../models/answer_record.dart';
import '../models/celebration_event.dart';
import '../models/user_progress.dart';

class AppState {
  final UserProgress progress;

  int _sessionStreak = 0;
  CelebrationEvent? _pendingDailyStreakEvent;

  static const int maxRecentAnswers = 50;

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
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
  }

  int _daysBetweenDateOnly(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  void onAppResumed({DateTime? now}) {
    final t = now ?? DateTime.now();

    final last = progress.lastOpenDate;
    progress.lastOpenDate = t;

    if (last == null) {
      if (progress.dailyStreak == 0) progress.dailyStreak = 1;
      return;
    }

    if (_dateKey(last) == _dateKey(t)) return;

    final diffDays = _daysBetweenDateOnly(last, t);

    if (diffDays == 1) {
      progress.dailyStreak += 1;
    } else if (diffDays > 1) {
      progress.dailyStreak = 1;
    } else {
      return;
    }

    _pendingDailyStreakEvent =
        CelebrationEvent.dailyStreakUpdated(progress.dailyStreak);

    if (kDebugMode) {
      debugPrint('Daily streak updated -> ${progress.dailyStreak}');
    }
  }

  List<CelebrationEvent> recordCaseSolved({
    required String caseId,
    required AnswerChoice userChoice,
    required bool isCorrect,
    required int difficulty,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    final events = <CelebrationEvent>[];
    final oldLevel = progress.level;

    // Prevent duplicates for built-in dataset (fine)
    final wasNew = progress.solvedCaseIds.add(caseId);
    if (wasNew) {
      progress.casesSolvedTotal += 1;
    }

    // ✅ Record answer (bounded)
    progress.recentAnswers.add(
      AnswerRecord(
        caseId: caseId,
        answeredAt: t,
        userChoice: userChoice,
        wasCorrect: isCorrect,
      ),
    );
    if (progress.recentAnswers.length > maxRecentAnswers) {
      // remove oldest extras
      final extra = progress.recentAnswers.length - maxRecentAnswers;
      progress.recentAnswers.removeRange(0, extra);
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

    final unlockedAchievementIds = _evaluateAndUnlockAchievements(t);
    for (final id in unlockedAchievementIds) {
      events.add(CelebrationEvent.achievementUnlocked(id));
    }

    final newLevel = progress.level;
    if (newLevel > oldLevel) {
      events.add(CelebrationEvent.levelUp(oldLevel, newLevel));
    }

    if (_pendingDailyStreakEvent != null) {
      events.insert(0, _pendingDailyStreakEvent!);
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
