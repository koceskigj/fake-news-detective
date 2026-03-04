class CaseItem {
  final String id;
  final String title;
  final String snippet;
  final String sourceName;
  final bool isFake;
  final String explanation;
  final int difficulty;
  final List<String> tags;

  // NEW (for user_cases)
  final String? createdBy;
  final String? status;

  CaseItem({
    required this.id,
    required this.title,
    required this.snippet,
    required this.sourceName,
    required this.isFake,
    required this.explanation,
    required this.difficulty,
    required this.tags,
    this.createdBy,
    this.status,
  });

  String get sourceCollection {
    if (createdBy != null || status != null) return 'user_cases';
    return 'ai_cases';
  }

  factory CaseItem.fromFirestore(String id, Map<String, dynamic> data) {
    return CaseItem(
      id: id,
      title: (data['title'] ?? '') as String,
      snippet: (data['snippet'] ?? '') as String,
      sourceName: (data['sourceName'] ?? '') as String,
      isFake: (data['isFake'] ?? false) as bool,
      explanation: (data['explanation'] ?? '') as String,
      difficulty: (data['difficulty'] ?? 1) is int
          ? data['difficulty'] as int
          : (data['difficulty'] as num).toInt(),
      tags: ((data['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
      createdBy: data['createdBy']?.toString(),
      status: data['status']?.toString(),
    );
  }
}
