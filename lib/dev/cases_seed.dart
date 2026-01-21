import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/sample_cases.dart';

class CasesSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedFromLocalSample() async {
    final col = _db.collection('cases');

    for (final c in sampleCases) {
      await col.doc(c.id).set({
        'title': c.title,
        'snippet': c.snippet,
        'sourceName': c.sourceName,
        'isFake': c.isFake,
        'explanation': c.explanation,
        'tags': c.tags,
        'difficulty': c.difficulty,
        'domainHint': c.domainHint,
      }, SetOptions(merge: true));
    }
  }

  Future<void> clearAll() async {
    final col = _db.collection('cases');
    final snap = await col.get();
    for (final d in snap.docs) {
      await d.reference.delete();
    }
  }
}
