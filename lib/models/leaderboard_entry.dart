class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String avatarKey;
  final int xp;
  final int level;
  final int bestDailyStreak;
  final int bestPerfectStreak;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.avatarKey,
    required this.xp,
    required this.level,
    required this.bestDailyStreak,
    required this.bestPerfectStreak,
  });

  factory LeaderboardEntry.fromMap(String userId, Map<String, dynamic> data) {
    int toInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    return LeaderboardEntry(
      userId: userId,
      displayName: (data['displayName'] as String?) ?? 'Anonymous',
      avatarKey: (data['avatarKey'] as String?) ?? 'monkey',
      xp: toInt(data['xp']),
      level: toInt(data['level'], 1),
      bestDailyStreak: toInt(data['bestDailyStreak']),
      bestPerfectStreak: toInt(data['bestPerfectStreak']),
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'avatarKey': avatarKey,
    'xp': xp,
    'level': level,
    'bestDailyStreak': bestDailyStreak,
    'bestPerfectStreak': bestPerfectStreak,
    'updatedAt': DateTime.now().toIso8601String(),
  };
}
