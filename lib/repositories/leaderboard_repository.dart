import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';
import '../models/user_progress.dart';

class LeaderboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('leaderboard');

  Future<void> upsertFromProgress(UserProgress p) async {
    // Using your local userId as the doc id (MVP)
    final doc = _col.doc(p.userId);
    final entry = LeaderboardEntry(
      userId: p.userId,
      displayName: p.displayName,
      avatarKey: p.avatarKey,
      xp: p.xp,
      level: p.level,
      bestDailyStreak: p.bestDailyStreak,
      bestPerfectStreak: p.bestPerfectStreak,
    );
    await doc.set(entry.toMap(), SetOptions(merge: true));
  }

  Stream<List<LeaderboardEntry>> topByXp({int limit = 20}) {
    return _col
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => LeaderboardEntry.fromMap(d.id, d.data()))
        .toList());
  }
}
