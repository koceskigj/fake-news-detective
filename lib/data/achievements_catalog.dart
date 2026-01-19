import '../models/achievement.dart';

final List<Achievement> achievementsCatalog = [
  Achievement(
    id: 'ach_rookie',
    title: 'Rookie Detective',
    description: 'Solve 3 cases.',
    iconKey: 'badge_rookie',
    xpReward: 20,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 3,
    ),
  ),
  Achievement(
    id: 'ach_case_10',
    title: 'On the Case',
    description: 'Solve 10 cases.',
    iconKey: 'badge_case_10',
    xpReward: 50,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 10,
    ),
  ),
  Achievement(
    id: 'ach_sharp_eye',
    title: 'Sharp Eye',
    description: 'Get 5 correct answers.',
    iconKey: 'badge_sharp_eye',
    xpReward: 25,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 5,
    ),
  ),
  Achievement(
    id: 'ach_truth_hunter',
    title: 'Truth Hunter',
    description: 'Get 20 correct answers.',
    iconKey: 'badge_truth_hunter',
    xpReward: 80,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 20,
    ),
  ),
  Achievement(
    id: 'ach_perfect_5',
    title: 'Perfect 5',
    description: 'Answer 5 in a row correctly (best streak).',
    iconKey: 'badge_perfect_5',
    xpReward: 40,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 5,
    ),
  ),
  Achievement(
    id: 'ach_streak_3',
    title: 'Daily Habit',
    description: 'Maintain a 3-day daily streak.',
    iconKey: 'badge_streak_3',
    xpReward: 60,
    criteria: AchievementCriteria(
      type: AchievementType.dailyStreakDays,
      threshold: 3,
    ),
  ),
  Achievement(
    id: 'ach_xp_100',
    title: 'Leveling Up',
    description: 'Earn 100 XP total.',
    iconKey: 'badge_xp_100',
    xpReward: 30,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 100,
    ),
  ),
  Achievement(
    id: 'ach_xp_300',
    title: 'Senior Detective',
    description: 'Earn 300 XP total.',
    iconKey: 'badge_xp_300',
    xpReward: 90,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 300,
    ),
  ),
  Achievement(
    id: 'ach_case_25',
    title: 'Case Veteran',
    description: 'Solve 25 cases.',
    iconKey: 'badge_case_25',
    xpReward: 120,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 25,
    ),
  ),

  Achievement(
    id: 'ach_case_75',
    title: 'Relentless Detective',
    description: 'Solve 75 cases.',
    iconKey: 'badge_case_75',
    xpReward: 200,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 75,
    ),
  ),

  Achievement(
    id: 'ach_correct_50',
    title: 'Truth Specialist',
    description: 'Get 50 correct answers.',
    iconKey: 'badge_correct_50',
    xpReward: 150,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 50,
    ),
  ),

  Achievement(
    id: 'ach_perfect_10',
    title: 'Flawless Run',
    description: 'Answer 10 cases in a row correctly.',
    iconKey: 'badge_perfect_10',
    xpReward: 180,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 10,
    ),
  ),

  Achievement(
    id: 'ach_streak_7',
    title: 'Daily Discipline',
    description: 'Maintain a 7-day daily streak.',
    iconKey: 'badge_streak_7',
    xpReward: 200,
    criteria: AchievementCriteria(
      type: AchievementType.dailyStreakDays,
      threshold: 7,
    ),
  ),

  Achievement(
    id: 'ach_xp_600',
    title: 'Seasoned Investigator',
    description: 'Earn 600 XP total.',
    iconKey: 'badge_xp_600',
    xpReward: 180,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 600,
    ),
  ),

  Achievement(
    id: 'ach_xp_1000',
    title: 'Master of Detection',
    description: 'Earn 1000 XP total.',
    iconKey: 'badge_xp_1000',
    xpReward: 300,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 1000,
    ),
  ),

];
