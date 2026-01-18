import 'package:flutter/material.dart';
import '../models/answer_record.dart';
import '../widgets/branded_app_bar.dart';

class CaseReviewScreen extends StatelessWidget {
  final AnswerRecord record;

  const CaseReviewScreen({super.key, required this.record});

  String _choiceLabel(AnswerChoice c) => c == AnswerChoice.fake ? 'FAKE' : 'REAL';

  @override
  Widget build(BuildContext context) {
    final correctLabel = record.isFake ? 'FAKE' : 'REAL';

    return Scaffold(
      appBar: const BrandedAppBar(showDailyStreak: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.sourceName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    record.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(record.snippet),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: record.tags.take(6).map((t) => Chip(label: Text(t))).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(record.wasCorrect ? Icons.check_circle_outline : Icons.error_outline),
              title: const Text('Your answer'),
              subtitle: Text(_choiceLabel(record.userChoice)),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Correct answer'),
              subtitle: Text(correctLabel),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Explanation'),
              subtitle: Text(record.explanation),
            ),
          ),
        ],
      ),
    );
  }
}
