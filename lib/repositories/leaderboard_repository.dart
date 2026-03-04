import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';
import '../models/user_progress.dart';

class LeaderboardRepository {
  final FirebaseFirestore _db;
  LeaderboardRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('leaderboard');

  Future<void> upsertFromProgress(UserProgress p, {required String uid}) async {
    final doc = _col.doc(uid);

    final entry = LeaderboardEntry(
      userId: uid, // store auth uid here (consistent + useful)
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
