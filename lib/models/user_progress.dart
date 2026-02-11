import 'answer_record.dart';

class UserProgress {
  final String userId;

  /// 'student' | 'teacher' | null (null => show RoleGate)
  String? appMode;

  /// If teacher logs in (FirebaseAuth), store uid here (optional)
  String? teacherUid;

  /// ✅ NEW: separate language preference per role
  String? studentLocale; // "en" | "mk" | null
  String? teacherLocale; // "en" | "mk" | null

  String displayName;
  String avatarKey;

  int xp;
  int level;
  int bestDailyStreak;

  int dailyStreak;
  DateTime? lastOpenDate;

  bool hasOnboarded;
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
    this.appMode,
    this.teacherUid,
    this.studentLocale,
    this.teacherLocale,
    this.xp = 0,
    this.level = 1,
    this.bestDailyStreak = 0,
    this.displayName = 'Guest Detective',
    this.avatarKey = 'monkey',
    this.dailyStreak = 0,
    this.lastOpenDate,
    this.hasOnboarded = false,
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

  UserProgress copyWith({
    String? userId,
    String? appMode,
    String? teacherUid,
    bool clearTeacherUid = false,
    String? studentLocale,
    bool clearStudentLocale = false,
    String? teacherLocale,
    bool clearTeacherLocale = false,
    String? displayName,
    String? avatarKey,
    int? xp,
    int? level,
    int? bestDailyStreak,
    int? dailyStreak,
    DateTime? lastOpenDate,
    bool clearLastOpenDate = false,
    bool? hasOnboarded,
    int? casesSolvedTotal,
    int? correctAnswersTotal,
    int? bestPerfectStreak,
    int? sessionStreak,
    Set<String>? solvedCaseIds,
    Set<String>? unlockedAchievementIds,
    Map<String, DateTime>? achievementUnlockedAt,
    List<AnswerRecord>? recentAnswers,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      appMode: appMode ?? this.appMode,
      teacherUid: clearTeacherUid ? null : (teacherUid ?? this.teacherUid),
      studentLocale: clearStudentLocale ? null : (studentLocale ?? this.studentLocale),
      teacherLocale: clearTeacherLocale ? null : (teacherLocale ?? this.teacherLocale),
      displayName: displayName ?? this.displayName,
      avatarKey: avatarKey ?? this.avatarKey,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      bestDailyStreak: bestDailyStreak ?? this.bestDailyStreak,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastOpenDate: clearLastOpenDate ? null : (lastOpenDate ?? this.lastOpenDate),
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      casesSolvedTotal: casesSolvedTotal ?? this.casesSolvedTotal,
      correctAnswersTotal: correctAnswersTotal ?? this.correctAnswersTotal,
      bestPerfectStreak: bestPerfectStreak ?? this.bestPerfectStreak,
      sessionStreak: sessionStreak ?? this.sessionStreak,
      solvedCaseIds: solvedCaseIds ?? this.solvedCaseIds,
      unlockedAchievementIds: unlockedAchievementIds ?? this.unlockedAchievementIds,
      achievementUnlockedAt: achievementUnlockedAt ?? this.achievementUnlockedAt,
      recentAnswers: recentAnswers ?? this.recentAnswers,
    );
  }

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
    'appMode': appMode,
    'teacherUid': teacherUid,

    // ✅ NEW
    'studentLocale': studentLocale,
    'teacherLocale': teacherLocale,

    'xp': xp,
    'level': level,
    'bestDailyStreak': bestDailyStreak,
    'displayName': displayName,
    'avatarKey': avatarKey,
    'dailyStreak': dailyStreak,
    'lastOpenDate': lastOpenDate?.toIso8601String(),
    'hasOnboarded': hasOnboarded,
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
      userId: (json['userId'] as String?) ?? '',
      appMode: json['appMode'] as String?,
      teacherUid: json['teacherUid'] as String?,

      // ✅ NEW
      studentLocale: json['studentLocale'] as String?,
      teacherLocale: json['teacherLocale'] as String?,

      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      bestDailyStreak: (json['bestDailyStreak'] as num?)?.toInt() ?? 0,
      displayName: (json['displayName'] as String?) ?? 'Guest Detective',
      avatarKey: (json['avatarKey'] as String?) ?? 'monkey',
      dailyStreak: (json['dailyStreak'] as num?)?.toInt() ?? 0,
      lastOpenDate: json['lastOpenDate'] == null
          ? null
          : DateTime.parse(json['lastOpenDate'] as String),
      hasOnboarded: (json['hasOnboarded'] as bool?) ?? false,
      casesSolvedTotal: (json['casesSolvedTotal'] as num?)?.toInt() ?? 0,
      correctAnswersTotal: (json['correctAnswersTotal'] as num?)?.toInt() ?? 0,
      bestPerfectStreak: (json['bestPerfectStreak'] as num?)?.toInt() ?? 0,
      sessionStreak: (json['sessionStreak'] as num?)?.toInt() ?? 0,
      solvedCaseIds: ((json['solvedCaseIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
      unlockedAchievementIds: ((json['unlockedAchievementIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
      achievementUnlockedAt: unlockedAt,
      recentAnswers: answers,
    );

    p.recalcLevel();
    return p;
  }
}
