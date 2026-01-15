import 'package:flutter/material.dart';

import '../models/answer_record.dart';
import '../models/case_item.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/case_post_card.dart';

class CaseReviewScreen extends StatelessWidget {
  final CaseItem? caseItem; // may be null for future AI cases
  final AnswerRecord record;

  const CaseReviewScreen({
    super.key,
    required this.caseItem,
    required this.record,
  });

  String _choiceLabel(AnswerChoice c) => c == AnswerChoice.fake ? 'FAKE' : 'REAL';

  @override
  Widget build(BuildContext context) {
    final item = caseItem;

    final correctLabel = (item == null)
        ? 'Unknown'
        : (item.isFake ? 'FAKE' : 'REAL');

    return Scaffold(
      appBar: const BrandedAppBar(title: 'Case Review', showMascot: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (item != null) ...[
            CasePostCard(item: item),
            const SizedBox(height: 12),
          ] else ...[
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('This case is not available for full review yet.'),
                subtitle: Text('Later, AI-generated cases will be stored for review.'),
              ),
            ),
            const SizedBox(height: 12),
          ],

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

          if (item != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Explanation'),
                subtitle: Text(item.explanation),
              ),
            ),
        ],
      ),
    );
  }
}
