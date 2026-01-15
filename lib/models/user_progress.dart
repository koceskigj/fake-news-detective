class UserProgress {
  /// Local-only unique id
  final String userId;

  int xp;
  int level;

  /// Daily streak (opens on consecutive days)
  int dailyStreak;

  /// Last date the app was opened (used for streak logic later)
  DateTime? lastOpenDate;

  /// Total counters
  int casesSolvedTotal;
  int correctAnswersTotal;

  /// For “perfect streak in a session” you can compute on the fly,
  /// but we keep a best record if you want.
  int bestPerfectStreak;

  /// Which cases the user has already solved
  final Set<String> solvedCaseIds;

  /// Which achievements are unlocked
  final Set<String> unlockedAchievementIds;

  /// When each achievement was unlocked
  final Map<String, DateTime> achievementUnlockedAt;

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
  })  : solvedCaseIds = solvedCaseIds ?? <String>{},
        unlockedAchievementIds = unlockedAchievementIds ?? <String>{},
        achievementUnlockedAt = achievementUnlockedAt ?? <String, DateTime>{};

  /// Basic level formula (simple and readable)
  /// You can change this later without breaking UI.
  int computeLevelFromXp() {
    // Level 1: 0-99, Level 2: 100-219, Level 3: 220-359 ...
    // Slightly increasing requirement per level.
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
