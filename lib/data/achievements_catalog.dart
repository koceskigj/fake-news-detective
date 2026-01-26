import '../models/achievement.dart';

final List<Achievement> achievementsCatalog = [
  Achievement(
    id: 'baby_detective',
    title: 'Baby Detective',
    description: 'Solve 3 cases.',
    iconKey: 'baby_detective',
    xpReward: 20,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 3,
    ),
  ),
  Achievement(
    id: 'ach_on_the_case',
    title: 'On the Case',
    description: 'Solve 10 cases.',
    iconKey: 'on_the_case',
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
    iconKey: 'sharp_eye',
    xpReward: 25,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 5,
    ),
  ),

  //flagged achievement, no invite a friend link yet.
  Achievement(
    id: 'partners_in_crime',
    title: 'Partners in Crime',
    description: 'Send the invitation link to 1 dear friend to join you as a Fake News Detective.',
    iconKey: 'partners_in_crime',
    xpReward: 80,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 20,
    ),
  ),

  Achievement(
    id: 'bullseye',
    title: 'Bullseye',
    description: 'Solve 20 cases in a row correctly.',
    iconKey: 'bullseye',
    xpReward: 40,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 20,
    ),
  ),


  //flagged achievement, have not added a language
  Achievement(
    id: 'cena_de_detectives',
    title: 'Cena de Detectives',
    description: 'Solve 50 cases in Spanish.',
    iconKey: 'cena_de_detectives',
    xpReward: 25,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 50,
    ),
  ),


  //flagged achievement, have not implemented the unlock accordingly yet
  Achievement(
    id: 'ach_xp_100',
    title: 'Moonlight Dancer',
    description: 'Solve 26 cases between 11 PM and 01 AM.',
    iconKey: 'moonlight_dancer',
    xpReward: 30,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 100,
    ),
  ),

  //flagged achievement, not keeping track on exact dates the game is played
  Achievement(
    id: 'stojche_the_great',
    title: 'Stojche The Great',
    description: 'Solve a case on 2nd of August or 8th of September.',
    iconKey: 'stojche_the_great',
    xpReward: 90,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 300,
    ),
  ),

  //flagged achievement, I have no ask stojche button counter.
  Achievement(
    id: 'mad_scientist',
    title: 'Mad Scientist',
    description: 'Solve 20 cases in a row correctly without Stojche\'s help.',
    iconKey: 'mad_scientist',
    xpReward: 120,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 25,
    ),
  ),

  //flagged achievement, invite a friend not implemented yet.
  Achievement(
    id: 'invite_a_friend',
    title: 'Dream Team',
    description: 'Send the invitation link to 5 dear friends to join you as a Fake News Detectives.',
    iconKey: 'dream_team',
    xpReward: 200,
    criteria: AchievementCriteria(
      type: AchievementType.casesSolvedTotal,
      threshold: 75,
    ),
  ),

  //flagged achievement, not counting ask stojche button clicks yet.
  Achievement(
    id: 'truth_seeker',
    title: 'Truth Seeker',
    description: 'Ask for Stojche\'s assistance 50 times.',
    iconKey: 'truth_seeker',
    xpReward: 150,
    criteria: AchievementCriteria(
      type: AchievementType.correctAnswersTotal,
      threshold: 50,
    ),
  ),

  Achievement(
    id: 'ach_perfect_11',
    title: 'Ace Of Hearts',
    description: 'Answer 11 cases in a row correctly.',
    iconKey: 'ace_of_hearts',
    xpReward: 180,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 11,
    ),
  ),

  Achievement(
    id: 'daily_discipline',
    title: 'Daily Discipline',
    description: 'Maintain a 7-day daily streak.',
    iconKey: 'daily_discipline',
    xpReward: 200,
    criteria: AchievementCriteria(
      type: AchievementType.dailyStreakDays,
      threshold: 1,
    ),
  ),

  //flagged achievement, still not having a counter for the ask stojche button.
  Achievement(
    id: 'smile_generator',
    title: 'Smile Generator',
    description: 'Answer 10 cases in a row correctly alone, while Stojche is at the dentist.',
    iconKey: 'smile_generator',
    xpReward: 180,
    criteria: AchievementCriteria(
      type: AchievementType.perfectStreak,
      threshold: 10,
    ),
  ),

  //flagged achievement, not implemented yet
  Achievement(
    id: 'winter_wonderland',
    title: 'Winter Wonderland',
    description: 'Play 1000 cases between December 1st and January 31st.',
    iconKey: 'winter_wonderland',
    xpReward: 300,
    criteria: AchievementCriteria(
      type: AchievementType.xpTotal,
      threshold: 1000,
    ),
  ),

];
