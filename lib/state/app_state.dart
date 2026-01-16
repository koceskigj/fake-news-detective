import 'package:flutter/foundation.dart';
import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../models/answer_record.dart';
import '../models/celebration_event.dart';
import '../models/user_progress.dart';
import '../services/local_storage.dart';

class AppState {
  final UserProgress progress;

  CelebrationEvent? _pendingDailyStreakEvent;

  static const int maxRecentAnswers = 50;

  AppState({required this.progress});

  /// ✅ Persisted session streak (consecutive correct answers)
  int get sessionStreak => progress.sessionStreak;

  int targetDifficultyFromStreak() {
    if (progress.sessionStreak >= 5) return 3;
    if (progress.sessionStreak >= 3) return 2;
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

  Future<void> _save() async {
    try {
      await LocalStorage.saveProgressJson(progress.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('Save failed: $e');
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

  Future<void> onAppResumed({DateTime? now}) async {
    final t = now ?? DateTime.now();

    final last = progress.lastOpenDate;
    progress.lastOpenDate = t;

    if (last == null) {
      if (progress.dailyStreak == 0) progress.dailyStreak = 1;
      await _save();
      return;
    }

    // Same calendar day: just save last open time
    if (_dateKey(last) == _dateKey(t)) {
      await _save();
      return;
    }

    final diffDays = _daysBetweenDateOnly(last, t);

    if (diffDays == 1) {
      progress.dailyStreak += 1;
    } else if (diffDays > 1) {
      progress.dailyStreak = 1;
    } else {
      // device time went backwards; ignore
      await _save();
      return;
    }

    // Optional UX choice:
    // If you want session streak to reset each new day, uncomment this:
    // progress.sessionStreak = 0;

    _pendingDailyStreakEvent =
        CelebrationEvent.dailyStreakUpdated(progress.dailyStreak);

    await _save();
  }

  Future<List<CelebrationEvent>> recordCaseSolved({
    required String caseId,
    required AnswerChoice userChoice,
    required bool isCorrect,
    required int difficulty,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final events = <CelebrationEvent>[];
    final oldLevel = progress.level;

    // Prevent repeats for built-in dataset
    final wasNew = progress.solvedCaseIds.add(caseId);
    if (wasNew) progress.casesSolvedTotal += 1;

    // Record bounded answer history
    progress.recentAnswers.add(
      AnswerRecord(
        caseId: caseId,
        answeredAt: t,
        userChoice: userChoice,
        wasCorrect: isCorrect,
      ),
    );
    if (progress.recentAnswers.length > maxRecentAnswers) {
      final extra = progress.recentAnswers.length - maxRecentAnswers;
      progress.recentAnswers.removeRange(0, extra);
    }

    if (isCorrect) {
      progress.correctAnswersTotal += 1;

      // ✅ persisted session streak
      progress.sessionStreak += 1;
      if (progress.sessionStreak > progress.bestPerfectStreak) {
        progress.bestPerfectStreak = progress.sessionStreak;
      }

      progress.awardXp(xpForDifficulty(difficulty));
    } else {
      // reset persisted streak
      progress.sessionStreak = 0;
    }

    final unlockedAchievementIds = _evaluateAndUnlockAchievements(t);
    for (final id in unlockedAchievementIds) {
      events.add(CelebrationEvent.achievementUnlocked(id));
    }

    final newLevel = progress.level;
    if (newLevel > oldLevel) {
      events.add(CelebrationEvent.levelUp(oldLevel, newLevel));
    }

    // Inject daily streak celebration after first solved case of the day
    if (_pendingDailyStreakEvent != null) {
      events.insert(0, _pendingDailyStreakEvent!);
      _pendingDailyStreakEvent = null;
    }

    await _save();
    return events;
  }

  Future<void> addXp(int amount, {DateTime? now}) async {
    progress.awardXp(amount);
    _evaluateAndUnlockAchievements(now ?? DateTime.now());
    await _save();
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
      }
    }

    return unlocked;
  }

  Future<void> resetProgress() async {
    // Clear persisted storage
    await LocalStorage.clearAll();

    // Reset in-memory progress fields
    progress.xp = 0;
    progress.level = 1;

    progress.dailyStreak = 0;
    progress.lastOpenDate = null;

    progress.casesSolvedTotal = 0;
    progress.correctAnswersTotal = 0;
    progress.bestPerfectStreak = 0;

    // Persisted session streak (🔥)
    progress.sessionStreak = 0;

    progress.solvedCaseIds.clear();
    progress.unlockedAchievementIds.clear();
    progress.achievementUnlockedAt.clear();
    progress.recentAnswers.clear();

    // Clear pending daily streak celebration
    _pendingDailyStreakEvent = null;

    // Save clean state so next launch is clean too
    await LocalStorage.saveProgressJson(progress.toJson());
  }


}
