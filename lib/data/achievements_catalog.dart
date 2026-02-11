
import '../models/achievement.dart';

final List<Achievement> achievementsCatalog = [
  Achievement(
    id: 'baby_detective',
    title: 'ach_baby_detective_title',
    description: 'ach_baby_detective_desc',
    iconKey: 'baby_detective',
    xpReward: 20,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 3,
    ),
  ),
  Achievement(
    id: 'ach_on_the_case',
    title: 'ach_on_the_case_title',
    description: 'ach_on_the_case_desc',
    iconKey: 'on_the_case',
    xpReward: 50,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 10,
    ),
  ),
  Achievement(
    id: 'ach_sharp_eye',
    title: 'ach_sharp_eye_title',
    description: 'ach_sharp_eye_desc',
    iconKey: 'sharp_eye',
    xpReward: 25,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 5,
    ),
  ),
  Achievement(
    id: 'partners_in_crime',
    title: 'ach_partners_in_crime_title',
    description: 'ach_partners_in_crime_desc',
    iconKey: 'partners_in_crime',
    xpReward: 80,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 20,
    ),
  ),
  Achievement(
    id: 'bullseye',
    title: 'ach_bullseye_title',
    description: 'ach_bullseye_desc',
    iconKey: 'bullseye',
    xpReward: 40,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 20,
    ),
  ),
  Achievement(
    id: 'cena_de_detectives',
    title: 'ach_cena_de_detectives_title',
    description: 'ach_cena_de_detectives_desc',
    iconKey: 'cena_de_detectives',
    xpReward: 25,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 50,
    ),
  ),
  Achievement(
    id: 'ach_xp_100',
    title: 'ach_moonlight_dancer_title',
    description: 'ach_moonlight_dancer_desc',
    iconKey: 'moonlight_dancer',
    xpReward: 30,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 100,
    ),
  ),
  Achievement(
    id: 'stojche_the_great',
    title: 'ach_stojche_the_great_title',
    description: 'ach_stojche_the_great_desc',
    iconKey: 'stojche_the_great',
    xpReward: 90,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 300,
    ),
  ),
  Achievement(
    id: 'mad_scientist',
    title: 'ach_mad_scientist_title',
    description: 'ach_mad_scientist_desc',
    iconKey: 'mad_scientist',
    xpReward: 120,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 25,
    ),
  ),
  Achievement(
    id: 'invite_a_friend',
    title: 'ach_dream_team_title',
    description: 'ach_dream_team_desc',
    iconKey: 'dream_team',
    xpReward: 200,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 75,
    ),
  ),
  Achievement(
    id: 'truth_seeker',
    title: 'ach_truth_seeker_title',
    description: 'ach_truth_seeker_desc',
    iconKey: 'truth_seeker',
    xpReward: 150,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 50,
    ),
  ),
  Achievement(
    id: 'ach_perfect_11',
    title: 'ach_ace_of_hearts_title',
    description: 'ach_ace_of_hearts_desc',
    iconKey: 'ace_of_hearts',
    xpReward: 180,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 11,
    ),
  ),
  Achievement(
    id: 'daily_discipline',
    title: 'ach_daily_discipline_title',
    description: 'ach_daily_discipline_desc',
    iconKey: 'daily_discipline',
    xpReward: 200,
    criteria: AchievementCriteria(
      type: AchievementType.dailyStreakDays,
      threshold: 1,
    ),
  ),
  Achievement(
    id: 'smile_generator',
    title: 'ach_smile_generator_title',
    description: 'ach_smile_generator_desc',
    iconKey: 'smile_generator',
    xpReward: 180,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 10,
    ),
  ),
  Achievement(
    id: 'winter_wonderland',
    title: 'ach_winter_wonderland_title',
    description: 'ach_winter_wonderland_desc',
    iconKey: 'winter_wonderland',
    xpReward: 300,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 1000,
    ),
  ),
];
