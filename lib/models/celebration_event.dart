enum CelebrationEventType {
  achievementUnlocked,
  levelUp,
  dailyStreakUpdated,
}

class CelebrationEvent {
  final CelebrationEventType type;

  // Achievement
  final String? achievementId;

  // Level up
  final int? oldLevel;
  final int? newLevel;

  // Daily streak
  final int? newDailyStreak;

  const CelebrationEvent._({
    required this.type,
    this.achievementId,
    this.oldLevel,
    this.newLevel,
    this.newDailyStreak,
  });

  factory CelebrationEvent.achievementUnlocked(String achievementId) {
    return CelebrationEvent._(
      type: CelebrationEventType.achievementUnlocked,
      achievementId: achievementId,
    );
  }

  factory CelebrationEvent.levelUp(int oldLevel, int newLevel) {
    return CelebrationEvent._(
      type: CelebrationEventType.levelUp,
      oldLevel: oldLevel,
      newLevel: newLevel,
    );
  }

  factory CelebrationEvent.dailyStreakUpdated(int newStreak) {
    return CelebrationEvent._(
      type: CelebrationEventType.dailyStreakUpdated,
      newDailyStreak: newStreak,
    );
  }
}
