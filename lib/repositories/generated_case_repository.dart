import 'dart:math';

import '../models/case_item.dart';
import '../models/user_progress.dart';
import 'case_repository.dart';

class GeneratedCaseRepository implements CaseRepository {
  final Random _rng = Random();

  // We still provide an initial pool (empty) and rely on generateCase()
  @override
  Future<List<CaseItem>> loadInitialCases() async {
    return <CaseItem>[];
  }

  static const _topics = [
    'health',
    'technology',
    'school',
    'weather',
    'sports',
    'travel',
    'science',
    'community',
  ];

  static const _places = [
    'Skopje',
    'Bitola',
    'Ohrid',
    'Tetovo',
    'Stip',
    'Kumanovo',
    'Prilep',
  ];

  static const _sourcesReal = [
    'Community Bulletin',
    'Local News Desk',
    'Public Service Update',
    'School Newsletter',
    'Regional Report',
  ];

  static const _sourcesFake = [
    'ViralDaily',
    'TruthNow Blog',
    'BreakingBuzz',
    'ShockFeed',
    'MiracleTimes',
  ];

  // Fake patterns (safe, educational)
  static const _fakePatterns = [
    'clickbait',
    'missing-source',
    'fearbait',
    'absurd-claim',
    'context-missing',
  ];

  String _id() => 'gen_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(9999)}';

  int _randInt(int min, int maxInclusive) {
    return min + _rng.nextInt(maxInclusive - min + 1);
  }

  T _pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

  @override
  Future<CaseItem?> generateCase({
    required UserProgress progress,
    required int targetDifficulty,
  }) async {
    final difficulty = targetDifficulty.clamp(1, 3);

    // 55% fake, 45% real (you can tweak)
    final isFake = _rng.nextDouble() < 0.55;

    final topic = _pick(_topics);
    final place = _pick(_places);

    if (isFake) {
      final pattern = _pick(_fakePatterns);
      return _generateFake(
        id: _id(),
        topic: topic,
        place: place,
        difficulty: difficulty,
        pattern: pattern,
      );
    } else {
      return _generateReal(
        id: _id(),
        topic: topic,
        place: place,
        difficulty: difficulty,
      );
    }
  }

  CaseItem _generateReal({
    required String id,
    required String topic,
    required String place,
    required int difficulty,
  }) {
    final source = _pick(_sourcesReal);

    // Keep “real” items modest and specific
    final titles = <String>[
      'City in $place announces a small update for $topic',
      'School in $place starts a new $topic activity for students',
      'Public service note in $place: changes related to $topic',
      'Community in $place plans a new $topic initiative this month',
    ];

    final snippets = <String>[
      'Officials shared practical details and a clear timeline. The update focuses on safety, planning, and community impact.',
      'The announcement includes what will change, when it starts, and who is affected. No extreme claims were made.',
      'The message gives a short explanation and encourages citizens to check the official notice for details.',
    ];

    return CaseItem(
      id: id,
      title: _pick(titles),
      snippet: _pick(snippets),
      sourceName: source,
      isFake: false,
      explanation:
      'This looks credible because it is specific and modest, avoids emotional pressure, and reads like a typical announcement.',
      tags: ['credible-tone', 'specific-details', topic],
      difficulty: difficulty,
      domainHint: 'news.example',
    );
  }

  CaseItem _generateFake({
    required String id,
    required String topic,
    required String place,
    required int difficulty,
    required String pattern,
  }) {
    final source = _pick(_sourcesFake);

    // Make harder cases less obviously silly (still safe)
    final intensity = difficulty; // 1..3

    String title;
    String snippet;
    List<String> tags = [topic];

    switch (pattern) {
      case 'clickbait':
        title = intensity == 1
            ? 'You WON’T believe what happened in $place about $topic!'
            : intensity == 2
            ? 'Shocking $topic update in $place—what they “hide” from you'
            : 'Hidden truth: the real reason $topic is “changing” in $place';
        snippet =
        'The post uses dramatic language and vague claims but provides no solid source. It encourages quick sharing.';
        tags.addAll(['clickbait', 'sharebait']);
        break;

      case 'missing-source':
        title = intensity == 1
            ? 'A “study” proves something huge about $topic in $place'
            : intensity == 2
            ? 'Experts say $topic is “dangerous” in $place (no names given)'
            : 'New report claims $topic will affect everyone in $place—details missing';
        snippet =
        'It references “experts” or “research” without naming who, where it was published, or how to verify it.';
        tags.addAll(['missing-source', 'vague-evidence']);
        break;

      case 'fearbait':
        title = intensity == 1
            ? 'WARNING: $topic threat in $place—share to stay safe'
            : intensity == 2
            ? 'URGENT alert about $topic in $place (act now!)'
            : 'Emergency message: $topic risk in $place—do this immediately';
        snippet =
        'Fear-based posts try to make you act fast. Real advisories usually include clear sources and calm guidance.';
        tags.addAll(['fearbait', 'urgent-language']);
        break;

      case 'context-missing':
        title = intensity == 1
            ? 'This short clip “proves” a $topic scandal in $place'
            : intensity == 2
            ? 'Viral screenshot shows $topic drama in $place—full context missing'
            : 'One quote changes everything about $topic in $place (but it’s incomplete)';
        snippet =
        'Short clips, screenshots, or cropped quotes can remove context. Verification needs the full source and time/place.';
        tags.addAll(['context-missing', 'cropped-clip']);
        break;

      case 'absurd-claim':
      default:
        title = intensity == 1
            ? 'Scientists confirm: $topic works like magic in $place'
            : intensity == 2
            ? 'New discovery: $topic “breaks the rules” in $place'
            : 'Unbelievable claim: $topic changes reality in $place (no proof)';
        snippet =
        'Absurd claims often rely on surprise instead of evidence. If it sounds magical, demand credible sources.';
        tags.addAll(['absurd-claim', 'too-good-to-be-true']);
        break;
    }

    return CaseItem(
      id: id,
      title: title,
      snippet: snippet,
      sourceName: source,
      isFake: true,
      explanation:
      'Red flags: $pattern, vague sources, emotional pressure, and lack of verifiable details. Always check who said it and where it was published.',
      tags: tags,
      difficulty: difficulty,
      domainHint: 'viral.example',
    );
  }
}
