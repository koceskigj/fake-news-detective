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
}
