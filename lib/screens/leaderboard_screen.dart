import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/leaderboard_entry.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('leaderboard');

  Stream<List<LeaderboardEntry>> _top20Stream() {
    return _col
        .orderBy('xp', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => LeaderboardEntry.fromMap(d.id, d.data()))
        .toList());
  }

  Future<LeaderboardEntry?> _loadMe(String myId) async {
    final doc = await _col.doc(myId).get().timeout(const Duration(seconds: 6));
    if (!doc.exists) return null;
    return LeaderboardEntry.fromMap(doc.id, doc.data()!);
  }

  Future<int?> _loadMyRank(LeaderboardEntry me) async {
    final q = _col.where('xp', isGreaterThan: me.xp);

    final agg = await q.count().get().timeout(const Duration(seconds: 6));
    final above = agg.count ?? 0;

    return above + 1;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final myId = appState.progress.userId;

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Leaderboard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<LeaderboardEntry>>(
                stream: _top20Stream(),
                builder: (context, topSnap) {
                  if (topSnap.hasError) {
                    return Center(
                      child: Text('Leaderboard error: ${topSnap.error}'),
                    );
                  }
                  if (!topSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final top = topSnap.data!;
                  if (top.isEmpty) {
                    return const Center(child: Text('No leaderboard entries yet.'));
                  }

                  final inTop20 = top.any((e) => e.userId == myId);

                  return FutureBuilder<LeaderboardEntry?>(
                    future: _loadMe(myId),
                    builder: (context, meSnap) {
                      final me = meSnap.data;

                      return ListView(
                        children: [
                          ...List.generate(top.length, (i) {
                            final e = top[i];
                            final isMe = e.userId == myId;

                            return _LeaderboardRow(
                              rankText: '#${i + 1}',
                              entry: e,
                              highlight: isMe,
                            );
                          }),

                          if (!inTop20) ...[
                            const SizedBox(height: 10),
                            const _DotsDivider(),
                            const SizedBox(height: 10),

                            if (meSnap.hasError)
                              const Card(
                                child: ListTile(
                                  leading: Icon(Icons.info_outline),
                                  title: Text('Could not load your entry'),
                                  subtitle: Text('Try again later.'),
                                ),
                              )
                            else if (me == null)
                              const Card(
                                child: ListTile(
                                  leading: Icon(Icons.info_outline),
                                  title: Text('Your score is not uploaded yet.'),
                                  subtitle: Text('Play a case to sync your XP to the leaderboard.'),
                                ),
                              )
                            else
                              FutureBuilder<int?>(
                                future: _loadMyRank(me),
                                builder: (context, rankSnap) {
                                  if (rankSnap.hasError) {
                                    return const Card(
                                      child: ListTile(
                                        leading: Icon(Icons.info_outline),
                                        title: Text('Rank unavailable right now'),
                                        subtitle: Text('Try again later.'),
                                      ),
                                    );
                                  }

                                  if (!rankSnap.hasData) {
                                    return const Card(
                                      child: ListTile(
                                        leading: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        title: Text('Loading your rank…'),
                                      ),
                                    );
                                  }

                                  final rank = rankSnap.data!;
                                  return _LeaderboardRow(
                                    rankText: '#$rank',
                                    entry: me,
                                    highlight: true,
                                  );
                                },
                              ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsDivider extends StatelessWidget {
  const _DotsDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        '• • •',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: cs.onSurfaceVariant,
          letterSpacing: 6,
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final String rankText;
  final LeaderboardEntry entry;
  final bool highlight;

  const _LeaderboardRow({
    required this.rankText,
    required this.entry,
    required this.highlight,
  });

  IconData _iconForAvatarKey(String key) {
    switch (key) {
      case 'detective':
        return Icons.manage_search;
      case 'owl':
        return Icons.visibility;
      case 'robot':
        return Icons.smart_toy_outlined;
      case 'fox':
        return Icons.pets_outlined;
      case 'star':
        return Icons.star_outline;
      case 'bolt':
        return Icons.bolt;
      case 'shield':
        return Icons.shield_outlined;
      case 'leaf':
        return Icons.eco_outlined;
      case 'monkey':
      default:
        return Icons.emoji_nature;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = highlight ? cs.primaryContainer : null;
    final fg = highlight ? cs.onPrimaryContainer : null;

    return Card(
      color: bg,
      child: ListTile(
        //Avatar on the left
        leading: CircleAvatar(
          backgroundColor: highlight
              ? cs.onPrimaryContainer.withOpacity(0.15)
              : cs.secondaryContainer,
          child: Icon(
            _iconForAvatarKey(entry.avatarKey),
            color: highlight ? cs.onPrimaryContainer : cs.onSecondaryContainer,
          ),
        ),

        title: Text(
          entry.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: fg,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        //XP + Level
        subtitle: Text(
          'XP ${entry.xp} • Level ${entry.level}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: fg?.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),

        // Rank on the right only
        trailing: Text(
          rankText,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: fg,
          ),
        ),
      ),
    );
  }
}

