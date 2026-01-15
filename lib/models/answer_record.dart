enum AnswerChoice { real, fake }

class AnswerRecord {
  final String caseId;
  final DateTime answeredAt;
  final AnswerChoice userChoice;
  final bool wasCorrect;

  const AnswerRecord({
    required this.caseId,
    required this.answeredAt,
    required this.userChoice,
    required this.wasCorrect,
  });

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'answeredAt': answeredAt.toIso8601String(),
    'userChoice': userChoice.name,
    'wasCorrect': wasCorrect,
  };

  static AnswerRecord fromJson(Map<String, dynamic> json) {
    return AnswerRecord(
      caseId: json['caseId'] as String,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      userChoice: (json['userChoice'] as String) == 'fake'
          ? AnswerChoice.fake
          : AnswerChoice.real,
      wasCorrect: json['wasCorrect'] as bool,
    );
  }
}
