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

class AppState extends ChangeNotifier {
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

  /// Local save is awaited; Firestore sync is NOT awaited (so UI stays smooth).
  Future<void> _save() async {
    try {
      await LocalStorage.saveProgressJson(progress.toJson());

      // Fire-and-forget leaderboard sync (avoid blocking UI)
      _leaderboardRepo.upsertFromProgress(progress).catchError((_) {});
    } catch (e) {
      if (kDebugMode) debugPrint('Save failed: $e');
    }
  }

  // ----------------------------
  // Profile settings
  // ----------------------------

  Future<void> setDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    progress.displayName = trimmed;
    notifyListeners();
    await _save();
  }

  Future<void> setAvatarKey(String key) async {
    progress.avatarKey = key;
    notifyListeners();
    await _save();
  }

  Future<void> completeOnboarding({
    required String displayName,
    required String avatarKey,
  }) async {
    final name = displayName.trim();

    progress.displayName = name.isEmpty ? 'Guest Detective' : name;
    progress.avatarKey = avatarKey;
    progress.hasOnboarded = true;

    notifyListeners();
    await _save();
  }

  // ----------------------------
  // Daily streak logic
  // ----------------------------

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
      // first open
      if (progress.dailyStreak == 0) progress.dailyStreak = 1;
      if (progress.dailyStreak > progress.bestDailyStreak) {
        progress.bestDailyStreak = progress.dailyStreak;
      }
      notifyListeners();
      await _save();
      return;
    }

    // same calendar day
    if (_dateKey(last) == _dateKey(t)) {
      notifyListeners();
      await _save();
      return;
    }

    final diffDays = _daysBetweenDateOnly(last, t);
    if (diffDays == 1) {
      progress.dailyStreak += 1;
    } else if (diffDays > 1) {
      progress.dailyStreak = 1;
    } else {
      // clock went backwards, ignore
      notifyListeners();
      await _save();
      return;
    }

    if (progress.dailyStreak > progress.bestDailyStreak) {
      progress.bestDailyStreak = progress.dailyStreak;
    }

    // Queue celebration (shown in your celebration flow)
    _pendingDailyStreakEvent =
        CelebrationEvent.dailyStreakUpdated(progress.dailyStreak);

    notifyListeners();
    await _save();
  }

  // ----------------------------
  // Gameplay + achievements
  // ----------------------------

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

    // Prevent repeats for built-in pool
    final wasNew = progress.solvedCaseIds.add(caseId);
    if (wasNew) progress.casesSolvedTotal += 1;

    // Store snapshot in bounded answer history
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

    // Update counters / XP
    if (isCorrect) {
      progress.correctAnswersTotal += 1;

      progress.sessionStreak += 1;
      if (progress.sessionStreak > progress.bestPerfectStreak) {
        progress.bestPerfectStreak = progress.sessionStreak;
      }

      int xpGain = xpForDifficulty(difficulty);

      // Hint penalty: /3 rounded, min 1
      if (usedHint) {
        xpGain = (xpGain / 3).round();
        if (xpGain < 1) xpGain = 1;
      }

      progress.awardXp(xpGain);
    } else {
      progress.sessionStreak = 0;
    }

    // Achievement unlock checks
    final unlockedAchievementIds = _evaluateAndUnlockAchievements(t);
    for (final id in unlockedAchievementIds) {
      events.add(CelebrationEvent.achievementUnlocked(id));
    }

    // Level-up check
    final newLevel = progress.level;
    if (newLevel > oldLevel) {
      events.add(CelebrationEvent.levelUp(oldLevel, newLevel));
    }

    // Inject daily streak celebration (if any)
    if (_pendingDailyStreakEvent != null) {
      events.insert(0, _pendingDailyStreakEvent!);
      _pendingDailyStreakEvent = null;
    }

    notifyListeners();
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

  // ----------------------------
  // Reset
  // ----------------------------

  Future<void> resetProgress() async {
    await LocalStorage.clearAll();

    progress.xp = 0;
    progress.level = 1;

    progress.dailyStreak = 0;
    progress.bestDailyStreak = 0;
    progress.lastOpenDate = null;

    progress.casesSolvedTotal = 0;
    progress.correctAnswersTotal = 0;
    progress.bestPerfectStreak = 0;
    progress.sessionStreak = 0;

    progress.solvedCaseIds.clear();
    progress.unlockedAchievementIds.clear();
    progress.achievementUnlockedAt.clear();
    progress.recentAnswers.clear();

    // Reset profile basics + onboarding
    progress.displayName = 'Guest Detective';
    progress.avatarKey = 'monkey';
    progress.hasOnboarded = false;

    _pendingDailyStreakEvent = null;

    notifyListeners();

    // Save clean state locally + update leaderboard (fire-and-forget)
    await LocalStorage.saveProgressJson(progress.toJson());
    _leaderboardRepo.upsertFromProgress(progress).catchError((_) {});
  }
}