enum AnswerChoice { real, fake }

class AnswerRecord {
  final String caseId;
  final DateTime answeredAt;
  final AnswerChoice userChoice;
  final bool wasCorrect;

  final String title;
  final String snippet;
  final String sourceName;
  final bool isFake;
  final String explanation;
  final int difficulty;
  final List<String> tags;

  const AnswerRecord({
    required this.caseId,
    required this.answeredAt,
    required this.userChoice,
    required this.wasCorrect,
    required this.title,
    required this.snippet,
    required this.sourceName,
    required this.isFake,
    required this.explanation,
    required this.difficulty,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'answeredAt': answeredAt.toIso8601String(),
    'userChoice': userChoice.name,
    'wasCorrect': wasCorrect,
    'title': title,
    'snippet': snippet,
    'sourceName': sourceName,
    'isFake': isFake,
    'explanation': explanation,
    'difficulty': difficulty,
    'tags': tags,
  };

  static AnswerRecord fromJson(Map<String, dynamic> json) {
    return AnswerRecord(
      caseId: json['caseId'] as String,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      userChoice: (json['userChoice'] as String) == 'fake'
          ? AnswerChoice.fake
          : AnswerChoice.real,
      wasCorrect: json['wasCorrect'] as bool,
      title: (json['title'] as String?) ?? 'Untitled case',
      snippet: (json['snippet'] as String?) ?? '',
      sourceName: (json['sourceName'] as String?) ?? 'Unknown source',
      isFake: (json['isFake'] as bool?) ?? false,
      explanation: (json['explanation'] as String?) ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      tags: ((json['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
    );
  }
}
