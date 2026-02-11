// lib/l10n/l10n_ext.dart


import 'app_localizations.dart';

extension L10nKey on AppLocalizations {
  /// Get a localized string by "key" (manual mapping).
  /// Generated l10n doesn't support dynamic lookups, so we map keys here.
  String byKey(String key) {
    switch (key) {
    // -------------------------
    // Learn patterns
    // -------------------------
      case 'pattern_clickbait_title': return patternClickbaitTitle;
      case 'pattern_clickbait_short': return patternClickbaitShort;
      case 'pattern_clickbait_expl': return patternClickbaitExpl;
      case 'pattern_clickbait_c1': return patternClickbaitC1;
      case 'pattern_clickbait_c2': return patternClickbaitC2;
      case 'pattern_clickbait_c3': return patternClickbaitC3;
      case 'pattern_clickbait_c4': return patternClickbaitC4;

      case 'pattern_missing_source_title': return patternMissingSourceTitle;
      case 'pattern_missing_source_short': return patternMissingSourceShort;
      case 'pattern_missing_source_expl': return patternMissingSourceExpl;
      case 'pattern_missing_source_c1': return patternMissingSourceC1;
      case 'pattern_missing_source_c2': return patternMissingSourceC2;
      case 'pattern_missing_source_c3': return patternMissingSourceC3;
      case 'pattern_missing_source_c4': return patternMissingSourceC4;

      case 'pattern_context_title': return patternContextTitle;
      case 'pattern_context_short': return patternContextShort;
      case 'pattern_context_expl': return patternContextExpl;
      case 'pattern_context_c1': return patternContextC1;
      case 'pattern_context_c2': return patternContextC2;
      case 'pattern_context_c3': return patternContextC3;
      case 'pattern_context_c4': return patternContextC4;

      case 'pattern_fear_title': return patternFearTitle;
      case 'pattern_fear_short': return patternFearShort;
      case 'pattern_fear_expl': return patternFearExpl;
      case 'pattern_fear_c1': return patternFearC1;
      case 'pattern_fear_c2': return patternFearC2;
      case 'pattern_fear_c3': return patternFearC3;
      case 'pattern_fear_c4': return patternFearC4;

      case 'pattern_absurd_title': return patternAbsurdTitle;
      case 'pattern_absurd_short': return patternAbsurdShort;
      case 'pattern_absurd_expl': return patternAbsurdExpl;
      case 'pattern_absurd_c1': return patternAbsurdC1;
      case 'pattern_absurd_c2': return patternAbsurdC2;
      case 'pattern_absurd_c3': return patternAbsurdC3;
      case 'pattern_absurd_c4': return patternAbsurdC4;

      case 'pattern_domain_title': return patternDomainTitle;
      case 'pattern_domain_short': return patternDomainShort;
      case 'pattern_domain_expl': return patternDomainExpl;
      case 'pattern_domain_c1': return patternDomainC1;
      case 'pattern_domain_c2': return patternDomainC2;
      case 'pattern_domain_c3': return patternDomainC3;
      case 'pattern_domain_c4': return patternDomainC4;

    // -------------------------
    // Achievements
    // -------------------------
      case 'ach_baby_detective_title': return ach_baby_detective_title;
      case 'ach_baby_detective_desc': return ach_baby_detective_desc;

      case 'ach_on_the_case_title': return ach_on_the_case_title;
      case 'ach_on_the_case_desc': return ach_on_the_case_desc;

      case 'ach_sharp_eye_title': return ach_sharp_eye_title;
      case 'ach_sharp_eye_desc': return ach_sharp_eye_desc;

      case 'ach_partners_in_crime_title': return ach_partners_in_crime_title;
      case 'ach_partners_in_crime_desc': return ach_partners_in_crime_desc;

      case 'ach_bullseye_title': return ach_bullseye_title;
      case 'ach_bullseye_desc': return ach_bullseye_desc;

      case 'ach_cena_de_detectives_title': return ach_cena_de_detectives_title;
      case 'ach_cena_de_detectives_desc': return ach_cena_de_detectives_desc;

      case 'ach_moonlight_dancer_title': return ach_moonlight_dancer_title;
      case 'ach_moonlight_dancer_desc': return ach_moonlight_dancer_desc;

      case 'ach_stojche_the_great_title': return ach_stojche_the_great_title;
      case 'ach_stojche_the_great_desc': return ach_stojche_the_great_desc;

      case 'ach_mad_scientist_title': return ach_mad_scientist_title;
      case 'ach_mad_scientist_desc': return ach_mad_scientist_desc;

      case 'ach_dream_team_title': return ach_dream_team_title;
      case 'ach_dream_team_desc': return ach_dream_team_desc;

      case 'ach_truth_seeker_title': return ach_truth_seeker_title;
      case 'ach_truth_seeker_desc': return ach_truth_seeker_desc;

      case 'ach_ace_of_hearts_title': return ach_ace_of_hearts_title;
      case 'ach_ace_of_hearts_desc': return ach_ace_of_hearts_desc;

      case 'ach_daily_discipline_title': return ach_daily_discipline_title;
      case 'ach_daily_discipline_desc': return ach_daily_discipline_desc;

      case 'ach_smile_generator_title': return ach_smile_generator_title;
      case 'ach_smile_generator_desc': return ach_smile_generator_desc;

      case 'ach_winter_wonderland_title': return ach_winter_wonderland_title;
      case 'ach_winter_wonderland_desc': return ach_winter_wonderland_desc;

      default:
        return key; // fallback so you SEE missing keys
    }
  }
}
