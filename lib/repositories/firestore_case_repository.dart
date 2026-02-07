import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_item.dart';

class FirestoreCaseRepository {
  final FirebaseFirestore _db;
  FirestoreCaseRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<CaseItem?> getNextCase({
    required String myUid,
    required Set<String> solvedIds,
  }) async {
    // 1) AI cases first
    final ai = await _pickFromCollection(
      collection: 'ai_cases',
      solvedIds: solvedIds,
      myUid: myUid,
      requireApproved: false,
      excludeMyOwn: false,
    );
    if (ai != null) return ai;

    // 2) Then approved user cases (not created by me)
    final user = await _pickFromCollection(
      collection: 'user_cases',
      solvedIds: solvedIds,
      myUid: myUid,
      requireApproved: true,
      excludeMyOwn: true,
    );
    return user;
  }

  Future<CaseItem?> _pickFromCollection({
    required String collection,
    required Set<String> solvedIds,
    required String myUid,
    required bool requireApproved,
    required bool excludeMyOwn,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection(collection);

    if (requireApproved) {
      q = q.where('status', isEqualTo: 'approved');
    }

    // Pull a batch and filter locally (simple + thesis-friendly)
    final snap = await q.limit(80).get();

    final list = snap.docs
        .map((d) => CaseItem.fromFirestore(d.id, d.data()))
        .where((c) => !solvedIds.contains(c.id))
        .where((c) => !excludeMyOwn || (c.createdBy != null && c.createdBy != myUid))
        .toList();

    if (list.isEmpty) return null;

    list.shuffle(Random());
    return list.first;
  }
}
