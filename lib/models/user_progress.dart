import 'answer_record.dart';

class UserProgress {
  final String userId;

  int xp;
  int level;

  int dailyStreak;
  DateTime? lastOpenDate;

  int casesSolvedTotal;
  int correctAnswersTotal;
  int bestPerfectStreak;

  final Set<String> solvedCaseIds;
  final Set<String> unlockedAchievementIds;
  final Map<String, DateTime> achievementUnlockedAt;

  /// ✅ Bounded history: last N answers (newest appended last)
  final List<AnswerRecord> recentAnswers;

  UserProgress({
    required this.userId,
    this.xp = 0,
    this.level = 1,
    this.dailyStreak = 0,
    this.lastOpenDate,
    this.casesSolvedTotal = 0,
    this.correctAnswersTotal = 0,
    this.bestPerfectStreak = 0,
    Set<String>? solvedCaseIds,
    Set<String>? unlockedAchievementIds,
    Map<String, DateTime>? achievementUnlockedAt,
    List<AnswerRecord>? recentAnswers,
  })  : solvedCaseIds = solvedCaseIds ?? <String>{},
        unlockedAchievementIds = unlockedAchievementIds ?? <String>{},
        achievementUnlockedAt = achievementUnlockedAt ?? <String, DateTime>{},
        recentAnswers = recentAnswers ?? <AnswerRecord>[];

  int computeLevelFromXp() {
    int lvl = 1;
    int needed = 100;
    int remaining = xp;

    while (remaining >= needed) {
      remaining -= needed;
      lvl += 1;
      needed = 100 + (lvl - 1) * 20;
    }
    return lvl;
  }

  void recalcLevel() {
    level = computeLevelFromXp();
  }

  void awardXp(int amount) {
    xp += amount;
    if (xp < 0) xp = 0;
    recalcLevel();
  }

  bool isAchievementUnlocked(String achievementId) {
    return unlockedAchievementIds.contains(achievementId);
  }

  void unlockAchievement(String achievementId, DateTime when) {
    unlockedAchievementIds.add(achievementId);
    achievementUnlockedAt[achievementId] = when;
  }
}
