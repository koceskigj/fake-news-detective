import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/case_item.dart';
import '../models/user_progress.dart';
import 'case_repository.dart';

class FirestoreCaseRepository implements CaseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('cases');

  @override
  Future<List<CaseItem>> loadInitialCases() async {
    final snap = await _col.get();

    return snap.docs.map((d) {
      final data = d.data();

      int toInt(dynamic v, [int fallback = 1]) {
        if (v is int) return v;
        if (v is num) return v.toInt();
        return fallback;
      }

      final tagsRaw = (data['tags'] as List?) ?? const [];
      final tags = tagsRaw.map((e) => e.toString()).toList();

      return CaseItem(
        id: d.id,
        title: (data['title'] as String?) ?? 'Untitled',
        snippet: (data['snippet'] as String?) ?? '',
        sourceName: (data['sourceName'] as String?) ?? 'Unknown source',
        isFake: (data['isFake'] as bool?) ?? false,
        explanation: (data['explanation'] as String?) ?? '',
        tags: tags,
        difficulty: toInt(data['difficulty'], 1),
        domainHint: (data['domainHint'] as String?),
      );
    }).toList();
  }

  @override
  Future<CaseItem?> generateCase({
    required UserProgress progress,
    required int targetDifficulty,
  }) async {
    // Firestore repo doesn't generate; it only serves curated cases.
    return null;
  }
}
