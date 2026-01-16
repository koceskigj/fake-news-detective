import 'answer_record.dart';

class UserProgress {
  final String userId;
  String displayName;
  String avatarKey;


  int xp;
  int level;

  int dailyStreak;
  DateTime? lastOpenDate;

  int casesSolvedTotal;
  int correctAnswersTotal;
  int bestPerfectStreak;
  int sessionStreak;


  final Set<String> solvedCaseIds;
  final Set<String> unlockedAchievementIds;
  final Map<String, DateTime> achievementUnlockedAt;

  final List<AnswerRecord> recentAnswers;

  UserProgress({
    required this.userId,
    this.xp = 0,
    this.level = 1,
    this.displayName = 'Guest Detective',
    this.avatarKey = 'monkey',
    this.dailyStreak = 0,
    this.lastOpenDate,
    this.casesSolvedTotal = 0,
    this.correctAnswersTotal = 0,
    this.bestPerfectStreak = 0,
    this.sessionStreak = 0,
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

  void recalcLevel() => level = computeLevelFromXp();

  void awardXp(int amount) {
    xp += amount;
    if (xp < 0) xp = 0;
    recalcLevel();
  }

  bool isAchievementUnlocked(String achievementId) =>
      unlockedAchievementIds.contains(achievementId);

  void unlockAchievement(String achievementId, DateTime when) {
    unlockedAchievementIds.add(achievementId);
    achievementUnlockedAt[achievementId] = when;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'xp': xp,
    'level': level,
    'displayName': displayName,
    'avatarKey': avatarKey,
    'dailyStreak': dailyStreak,
    'lastOpenDate': lastOpenDate?.toIso8601String(),
    'casesSolvedTotal': casesSolvedTotal,
    'correctAnswersTotal': correctAnswersTotal,
    'bestPerfectStreak': bestPerfectStreak,
    'sessionStreak': sessionStreak,
    'solvedCaseIds': solvedCaseIds.toList(),
    'unlockedAchievementIds': unlockedAchievementIds.toList(),
    'achievementUnlockedAt': achievementUnlockedAt.map(
          (k, v) => MapEntry(k, v.toIso8601String()),
    ),
    'recentAnswers': recentAnswers.map((r) => r.toJson()).toList(),
  };

  static UserProgress fromJson(Map<String, dynamic> json) {
    final unlockedAtRaw = (json['achievementUnlockedAt'] as Map?) ?? {};
    final unlockedAt = <String, DateTime>{};
    for (final entry in unlockedAtRaw.entries) {
      unlockedAt[entry.key.toString()] = DateTime.parse(entry.value.toString());
    }

    final answersRaw = (json['recentAnswers'] as List?) ?? const [];
    final answers = answersRaw
        .whereType<Map>()
        .map((m) => AnswerRecord.fromJson(m.cast<String, dynamic>()))
        .toList();

    final p = UserProgress(
      userId: json['userId'] as String,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      displayName: (json['displayName'] as String?) ?? 'Guest Detective',
      avatarKey: (json['avatarKey'] as String?) ?? 'monkey',
      dailyStreak: (json['dailyStreak'] as num?)?.toInt() ?? 0,
      lastOpenDate: json['lastOpenDate'] == null
          ? null
          : DateTime.parse(json['lastOpenDate'] as String),
      casesSolvedTotal: (json['casesSolvedTotal'] as num?)?.toInt() ?? 0,
      correctAnswersTotal: (json['correctAnswersTotal'] as num?)?.toInt() ?? 0,
      bestPerfectStreak: (json['bestPerfectStreak'] as num?)?.toInt() ?? 0,
      sessionStreak: (json['sessionStreak'] as num?)?.toInt() ?? 0,
      solvedCaseIds: ((json['solvedCaseIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
      unlockedAchievementIds:
      ((json['unlockedAchievementIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
      achievementUnlockedAt: unlockedAt,
      recentAnswers: answers,
    );

    // Recalculate in case formula changes later
    p.recalcLevel();
    return p;
  }
}
