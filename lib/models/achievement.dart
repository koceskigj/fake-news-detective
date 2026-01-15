enum AchievementType {
  casesSolvedTotal,
  correctAnswersTotal,
  perfectStreak, // consecutive correct answers in a session
  dailyStreakDays,
  xpTotal,
}

class AchievementCriteria {
  final AchievementType type;
  final int threshold;

  const AchievementCriteria({
    required this.type,
    required this.threshold,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;

  /// Use an icon key now; later you can map it to an actual asset/image.
  final String iconKey;

  final int xpReward;
  final AchievementCriteria criteria;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.xpReward,
    required this.criteria,
  });
}
