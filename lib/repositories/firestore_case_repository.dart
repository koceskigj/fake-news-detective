import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/case_item.dart';

class FirestoreCaseRepository {
  final FirebaseFirestore _db;
  FirestoreCaseRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<CaseItem?> getNextCase({
    required String myUid,
    required Set<String> solvedIds,
  }) async {
    // 1) AI cases first (public read, easy)
    final ai = await _pickFromAiCases(
      solvedIds: solvedIds,
    );
    if (ai != null) return ai;

    // 2) Then approved user cases
    final user = await _pickFromApprovedUserCases(
      myUid: myUid,
      solvedIds: solvedIds,
      excludeMyOwn: true,
    );
    return user;
  }

  Future<CaseItem?> _pickFromAiCases({
    required Set<String> solvedIds,
  }) async {
    try {
      // AI cases are readable by everyone, ordering is fine
      final snap = await _db
          .collection('ai_cases')
          .orderBy('createdAt', descending: true)
          .limit(80)
          .get();

      final list = snap.docs
          .map((d) => CaseItem.fromFirestore(d.id, d.data()))
          .where((c) => !solvedIds.contains(c.id))
          .toList();

      if (list.isEmpty) return null;

      list.shuffle(Random());
      return list.first;
    } catch (e) {
      if (kDebugMode) debugPrint('AI query failed: $e');
      return null;
    }
  }

  Future<CaseItem?> _pickFromApprovedUserCases({
    required String myUid,
    required Set<String> solvedIds,
    required bool excludeMyOwn,
  }) async {
    try {
      // ✅ IMPORTANT:
      // Keep the query "status == approved" so Firestore rules allow the query.
      // ✅ DO NOT orderBy(createdAt) here, to avoid needing a composite index.
      final snap = await _db
          .collection('user_cases')
          .where('status', isEqualTo: 'approved')
          .limit(80)
          .get();

      final list = snap.docs
          .map((d) => CaseItem.fromFirestore(d.id, d.data()))
          .where((c) => !solvedIds.contains(c.id))
          .where((c) => !excludeMyOwn || (c.createdBy == null || c.createdBy != myUid))
          .toList();

      if (list.isEmpty) return null;

      list.shuffle(Random());
      return list.first;
    } catch (e) {
      if (kDebugMode) debugPrint('Approved user_cases query failed: $e');
      return null;
    }
  }
}
