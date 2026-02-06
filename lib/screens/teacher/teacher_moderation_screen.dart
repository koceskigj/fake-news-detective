import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class TeacherModerationScreen extends StatelessWidget {
  const TeacherModerationScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _pendingStream() {
    return FirebaseFirestore.instance
        .collection('user_cases')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  Future<void> _claim(BuildContext context, String caseId) async {
    final fn = FirebaseFunctions.instance.httpsCallable('claimUserCase');
    await fn.call({'caseId': caseId});
  }

  Future<void> _review(BuildContext context, String caseId, String decision) async {
    final fn = FirebaseFunctions.instance.httpsCallable('reviewUserCase');
    await fn.call({'caseId': caseId, 'decision': decision});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation queue')),
      body: StreamBuilder(
        stream: _pendingStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No pending cases 🎉'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();
              final title = (data['title'] ?? '').toString();
              final assignedTo = data['assignedTo'];

              return Card(
                child: ListTile(
                  title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Status: pending ${assignedTo != null ? "• claimed" : ""}'),
                  onTap: () async {
                    // show details + actions
                    await showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              const SizedBox(height: 10),
                              Text((data['snippet'] ?? '').toString()),
                              const SizedBox(height: 10),
                              Text('Explanation: ${(data['explanation'] ?? '').toString()}'),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _claim(context, d.id);
                                      },
                                      child: const Text('Claim'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _review(context, d.id, 'approved');
                                      },
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _review(context, d.id, 'rejected');
                                      },
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
