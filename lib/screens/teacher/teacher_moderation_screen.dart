import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/case_item.dart';
import '../../widgets/case_post_card.dart';
import '../../widgets/speech_bubble.dart';

class TeacherModerationScreen extends StatefulWidget {
  const TeacherModerationScreen({super.key});

  @override
  State<TeacherModerationScreen> createState() => _TeacherModerationScreenState();
}

class _TeacherModerationScreenState extends State<TeacherModerationScreen> {
  bool _working = false;

  String get _teacherUid => FirebaseAuth.instance.currentUser!.uid;

  Query<Map<String, dynamic>> _queryAssignedPending() {
    return FirebaseFirestore.instance
        .collection('user_cases')
        .where('assignedTo', isEqualTo: _teacherUid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .limit(1);
  }

  Future<void> _review({
    required String caseId,
    required String decision, // "approved" | "rejected"
  }) async {
    if (_working) return;
    setState(() => _working = true);

    try {
      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('reviewUserCase');

      await callable.call({
        'caseId': caseId,
        'decision': decision,
      });

      // Stream updates automatically:
      // - approved => status changes, disappears from pending
      // - rejected => doc deleted, disappears
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      String msg;
      switch (e.code) {
        case 'permission-denied':
          msg = 'No permission. This case may not be assigned to you.';
          break;
        case 'failed-precondition':
          msg = 'This case was already reviewed by someone else.';
          break;
        case 'not-found':
          msg = 'This case no longer exists.';
          break;
        default:
          msg = e.message ?? 'Action failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: monkey + speech bubble
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset(
                    'assets/stojche/stojche_idle.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SpeechBubble(
                    text: 'Approve good cases so students can play them.\n'
                        'Decline low quality ones.',
                    backgroundColor: cs.secondaryContainer,
                    textColor: cs.onSecondaryContainer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _queryAssignedPending().snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Moderation error: ${snap.error}\n\n'
                            'If it says “requires an index”, create the index in Firestore console.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No cases assigned right now.\nCome back later.',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final d = docs.first;
                  final item = CaseItem.fromFirestore(d.id, d.data());

                  return ListView(
                    children: [
                      CasePostCard(item: item),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _working
                                  ? null
                                  : () => _review(
                                caseId: item.id,
                                decision: 'approved',
                              ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Approve'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE6F4EA),
                                foregroundColor: const Color(0xFF1E7F43),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _working
                                  ? null
                                  : () => _review(
                                caseId: item.id,
                                decision: 'rejected',
                              ),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Decline'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFDEAEA),
                                foregroundColor: const Color(0xFFB3261E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_working) ...[
                        const SizedBox(height: 12),
                        const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ],
                    ],
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
