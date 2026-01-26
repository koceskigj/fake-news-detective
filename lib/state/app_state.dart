import 'package:flutter/foundation.dart';

import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../models/answer_record.dart';
import '../models/case_item.dart';
import '../models/celebration_event.dart';
import '../models/user_progress.dart';
import '../repositories/case_repository.dart';
import '../repositories/hybrid_case_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../services/local_storage.dart';

class AppState {
  final UserProgress progress;

  final CaseRepository caseRepository;

  final LeaderboardRepository _leaderboardRepo = LeaderboardRepository();

  CelebrationEvent? _pendingDailyStreakEvent;

  static const int maxRecentAnswers = 50;

  AppState({
    required this.progress,
    CaseRepository? caseRepository,
  }) : caseRepository = caseRepository ?? HybridCaseRepository();

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
      // Local save (fast)
      await LocalStorage.saveProgressJson(progress.toJson());

      // Firestore sync (do NOT block UI)
      _leaderboardRepo.upsertFromProgress(progress).catchError((_) {});
    } catch (e) {
      if (kDebugMode) debugPrint('Save failed: $e');
    }
  }

  // ✅ Needed for Profile screen
  Future<void> setDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    progress.displayName = trimmed;
    await _save();
  }

  // ✅ Needed for Profile screen
  Future<void> setAvatarKey(String key) async {
    progress.avatarKey = key;
    await _save();
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

    // First ever open
    if (last == null) {
      if (progress.dailyStreak == 0) progress.dailyStreak = 1;
      if (progress.dailyStreak > progress.bestDailyStreak) {
        progress.bestDailyStreak = progress.dailyStreak;
      }
      await _save();
      return;
    }

    // Same calendar day
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
      // clock moved backwards, ignore
      await _save();
      return;
    }

    if (progress.dailyStreak > progress.bestDailyStreak) {
      progress.bestDailyStreak = progress.dailyStreak;
    }

    _pendingDailyStreakEvent =
        CelebrationEvent.dailyStreakUpdated(progress.dailyStreak);

    await _save();
  }

  Future<List<CelebrationEvent>> recordCaseSolved({
    required String caseId,
    required AnswerChoice userChoice,
    required bool isCorrect,
    required int difficulty,
    required bool usedHint,
    required CaseItem item,
    DateTime? now,
  }) async {
    final DateTime t = now ?? DateTime.now();
    final events = <CelebrationEvent>[];
    final oldLevel = progress.level;

    // Prevent repeats for built-in pool (fine)
    final wasNew = progress.solvedCaseIds.add(caseId);
    if (wasNew) progress.casesSolvedTotal += 1;

    // Snapshot answer record (works for AI/generated too)
    progress.recentAnswers.add(
      AnswerRecord(
        caseId: caseId,
        answeredAt: t,
        userChoice: userChoice,
        wasCorrect: isCorrect,
        title: item.title,
        snippet: item.snippet,
        sourceName: item.sourceName,
        isFake: item.isFake,
        explanation: item.explanation,
        difficulty: item.difficulty,
        tags: item.tags,
      ),
    );

    if (progress.recentAnswers.length > maxRecentAnswers) {
      final extra = progress.recentAnswers.length - maxRecentAnswers;
      progress.recentAnswers.removeRange(0, extra);
    }

    if (isCorrect) {
      progress.correctAnswersTotal += 1;

      progress.sessionStreak += 1;
      if (progress.sessionStreak > progress.bestPerfectStreak) {
        progress.bestPerfectStreak = progress.sessionStreak;
      }

      int xpGain = xpForDifficulty(difficulty);

      if (usedHint) {
        xpGain = (xpGain / 3).round();
        if (xpGain < 1) xpGain = 1;
      }

      progress.awardXp(xpGain);
    } else {
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

    if (_pendingDailyStreakEvent != null) {
      events.insert(0, _pendingDailyStreakEvent!);
      _pendingDailyStreakEvent = null;
    }

    await _save();
    return events;
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

  Future<void> completeOnboarding({
    required String displayName,
    required String avatarKey,
  }) async {
    progress.displayName = displayName.trim().isEmpty ? 'Guest Detective' : displayName.trim();
    progress.avatarKey = avatarKey;
    progress.hasOnboarded = true;
    await setDisplayName(progress.displayName);
    await setAvatarKey(progress.avatarKey);
    // setDisplayName/setAvatarKey already save; but make sure hasOnboarded is saved too:
    await LocalStorage.saveProgressJson(progress.toJson());
  }

  Future<void> resetProgress() async {
    await LocalStorage.clearAll();

    progress.xp = 0;
    progress.level = 1;

    progress.dailyStreak = 0;
    progress.bestDailyStreak = 0;
    progress.lastOpenDate = null;

    progress.hasOnboarded = false;
    progress.displayName = 'Guest Detective';
    progress.avatarKey = 'monkey';
    progress.casesSolvedTotal = 0;
    progress.correctAnswersTotal = 0;
    progress.bestPerfectStreak = 0;
    progress.sessionStreak = 0;

    progress.solvedCaseIds.clear();
    progress.unlockedAchievementIds.clear();
    progress.achievementUnlockedAt.clear();
    progress.recentAnswers.clear();

    _pendingDailyStreakEvent = null;

    await LocalStorage.saveProgressJson(progress.toJson());
    _leaderboardRepo.upsertFromProgress(progress).catchError((_) {});
  }
}
