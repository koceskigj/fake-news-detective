import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherStatsScreen extends StatelessWidget {
  const TeacherStatsScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    return FirebaseFirestore.instance
        .collection('user_cases')
        .where('status', isEqualTo: 'approved')
        .orderBy('reviewedAt', descending: true)
        .limit(50)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Case statistics')),
      body: StreamBuilder(
        stream: _stream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No approved user cases yet.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final title = (d['title'] ?? '').toString();
              final stats = (d['stats'] ?? {}) as Map<String, dynamic>;
              final attempts = (stats['attempts'] ?? 0);
              final correct = (stats['correct'] ?? 0);
              final wrong = (stats['wrong'] ?? 0);

              return Card(
                child: ListTile(
                  title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Attempts $attempts • Correct $correct • Wrong $wrong'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
