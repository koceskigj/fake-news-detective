import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../data/achievements_catalog.dart';
import '../models/achievement.dart';
import '../models/answer_record.dart';
import '../models/case_item.dart';
import '../models/celebration_event.dart';
import '../models/user_progress.dart';
import '../repositories/firestore_case_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../services/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AppState extends ChangeNotifier {
  final UserProgress progress;

  /// ✅ Firestore-only cases
  final FirestoreCaseRepository caseRepository = FirestoreCaseRepository();

  final LeaderboardRepository _leaderboardRepo = LeaderboardRepository();

  CelebrationEvent? _pendingDailyStreakEvent;

  static const int maxRecentAnswers = 50;

  AppState({
    required this.progress,
  });

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

  // ----------------------------
  // Auth helpers
  // ----------------------------

  /// Ensure we have a Firebase user (anonymous is fine for students)
  Future<User?> _ensureAuthedUser() async {
    final auth = FirebaseAuth.instance;
    final u = auth.currentUser;
    if (u != null) return u;

    try {
      final cred = await auth.signInAnonymously().timeout(const Duration(seconds: 10));
      return cred.user;
    } catch (_) {
      return null;
    }
  }

  int _timeBucketFromHour(int hour) {
    // Your desired buckets:
    // 1AM-7AM, 7AM-1PM, 1PM-7PM, 7PM-1AM
    // We'll use:
    // [1..6] => b0
    // [7..12] => b1
    // [13..18] => b2
    // [19..23] and 0 => b3
    if (hour >= 1 && hour <= 6) return 0;
    if (hour >= 7 && hour <= 12) return 1;
    if (hour >= 13 && hour <= 18) return 2;
    return 3;
  }

  /// Fire-and-forget: store an "answer event" to backend (for stats charts).
  Future<void> _recordAnswerEvent({
    required String caseId,
    required bool isCorrect,
    required int difficulty,
    required bool usedHint,
    required AnswerChoice userChoice,
    required CaseItem item,
    required DateTime now,
  }) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;

    // If you ever call this while signed out, skip logging safely.
    if (authUid == null) return;

    // 4 buckets:
    // 01–06 => night, 07–12 => morning, 13–18 => afternoon, 19–00 => evening
    final h = now.hour;
    String bucket;
    if (h >= 1 && h < 7) {
      bucket = 'night';
    } else if (h >= 7 && h < 13) {
      bucket = 'morning';
    } else if (h >= 13 && h < 19) {
      bucket = 'afternoon';
    } else {
      bucket = 'evening'; // includes 19–23 and 00
    }

    final caseType = (item.status != null) ? 'user_case' : 'ai_case';

    await FirebaseFirestore.instance.collection('answer_events').add({
      'userUid': authUid,
      'caseId': caseId,
      'caseType': caseType,

      'isCorrect': isCorrect,
      'userChoice': userChoice.name, // "real"/"fake"
      'difficulty': difficulty,
      'usedHint': usedHint,

      // Time fields
      'answeredAt': FieldValue.serverTimestamp(), // canonical
      'hourLocal': h,
      'bucket': bucket,

      // Optional, useful for later filters
      'tags': item.tags,
      'createdBy': item.createdBy, // null for ai cases
    });
  }


  /// Local save is awaited; Firestore sync is NOT awaited (so UI stays smooth).
  Future<void> _save() async {
    try {
      await LocalStorage.saveProgressJson(progress.toJson());

      // ✅ IMPORTANT:
      // Leaderboard rules require docId == FirebaseAuth.uid.
      // So only sync leaderboard if we have an authed Firebase user.
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null) {
        _leaderboardRepo.upsertFromProgress(progress, uid: authUid).catchError((_) {});
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Save failed: $e');
    }
  }

  // ----------------------------
  // Teacher / Student mode
  // ----------------------------

  bool get isTeacherMode => (progress.appMode == 'teacher');
  bool get isStudentMode => (progress.appMode == 'student');

  Future<void> setAppModeStudent() async {
    progress.appMode = 'student';
    progress.teacherUid = null;
    notifyListeners();
    await _save();
  }

  Future<void> setAppModeTeacher() async {
    progress.appMode = 'teacher';
    // teacherUid stays null until login succeeds
    notifyListeners();
    await _save();
  }

  /// Call this when teacher login succeeds (FirebaseAuth)
  Future<void> setTeacherUid(String uid) async {
    progress.teacherUid = uid;
    progress.appMode = 'teacher';
    notifyListeners();
    await _save();
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

  /// Used by OnboardingFlow (student)
  Future<void> completeOnboarding({
    required String displayName,
    required String avatarKey,
  }) async {
    final name = displayName.trim();

    progress.displayName = name.isEmpty ? 'Guest Detective' : name;
    progress.avatarKey = avatarKey;
    progress.hasOnboarded = true;

    // Ensure student mode when completing onboarding
    progress.appMode = 'student';
    progress.teacherUid = null;

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
      if (progress.dailyStreak == 0) progress.dailyStreak = 1;
      if (progress.dailyStreak > progress.bestDailyStreak) {
        progress.bestDailyStreak = progress.dailyStreak;
      }
      notifyListeners();
      await _save();
      return;
    }

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
      notifyListeners();
      await _save();
      return;
    }

    if (progress.dailyStreak > progress.bestDailyStreak) {
      progress.bestDailyStreak = progress.dailyStreak;
    }

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

    // Prevent repeats
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

    // ✅ Fire-and-forget stats logging (never blocks UI)
    _recordAnswerEvent(
      caseId: caseId,
      isCorrect: isCorrect,
      difficulty: difficulty,
      usedHint: usedHint,
      userChoice: userChoice,
      item: item,
      now: t,
    ).catchError((_) {});

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
  // Reset + logout
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

    progress.displayName = 'Guest Detective';
    progress.avatarKey = 'monkey';
    progress.hasOnboarded = false;

    progress.appMode = null;
    progress.teacherUid = null;

    _pendingDailyStreakEvent = null;

    notifyListeners();

    await LocalStorage.saveProgressJson(progress.toJson());

    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null) {
      _leaderboardRepo.upsertFromProgress(progress, uid: authUid).catchError((_) {});
    }
  }

  Future<void> logoutTeacher() async {
    progress.teacherUid = null;
    progress.appMode = null;
    notifyListeners();
    await LocalStorage.saveProgressJson(progress.toJson());
  }
}
