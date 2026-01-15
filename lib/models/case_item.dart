class CaseItem {
  final String id;
  final String title;
  final String snippet;
  final String sourceName;
  final DateTime? publishedAt;

  /// True = fake/misleading, False = real/credible (within our dataset)
  final bool isFake;

  /// Explanation shown after the user answers.
  final String explanation;

  /// Tags like: clickbait, missing-source, manipulated-image, satire, context-missing
  final List<String> tags;

  /// 1 = easy, 2 = medium, 3 = hard
  final int difficulty;

  /// Optional: a fake URL string for “domain-checking” training later
  final String? domainHint;

  /// Optional: image/asset key for later (use icons/placeholders for now)
  final String? imageKey;

  const CaseItem({
    required this.id,
    required this.title,
    required this.snippet,
    required this.sourceName,
    required this.isFake,
    required this.explanation,
    this.publishedAt,
    this.tags = const [],
    this.difficulty = 1,
    this.domainHint,
    this.imageKey,
  });
}
