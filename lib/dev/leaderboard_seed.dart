import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _rng = Random();

  Future<void> seed({int count = 25}) async {
    final col = _db.collection('leaderboard');

    for (int i = 1; i <= count; i++) {
      final id = 'demo_user_${i.toString().padLeft(3, '0')}';
      final xp = 1500 + _rng.nextInt(2000); // 50..1549
      final level = 1 + (xp ~/ 120);
      final bestDaily = 1 + _rng.nextInt(14);
      final bestStreak = 1 + _rng.nextInt(15);

      await col.doc(id).set({
        'displayName': 'Demo Detective $i',
        'avatarKey': 'monkey',
        'xp': xp,
        'level': level,
        'bestDailyStreak': bestDaily,
        'bestPerfectStreak': bestStreak,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> clearDemo() async {
    final col = _db.collection('leaderboard');

    // Query docs whose IDs start with "demo_user_"
    final snap = await col
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'demo_user_')
        .where(FieldPath.documentId, isLessThan: 'demo_user_\uf8ff')
        .get();

    for (final d in snap.docs) {
      await d.reference.delete();
    }
  }
}
