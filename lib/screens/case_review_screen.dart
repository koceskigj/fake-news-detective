import 'package:flutter/material.dart';
import '../models/answer_record.dart';
import '../widgets/branded_app_bar.dart';
import '../l10n/app_localizations.dart';

class CaseReviewScreen extends StatelessWidget {
  final AnswerRecord record;

  const CaseReviewScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final correctLabel =
    record.isFake ? l10n.fakeUpper : l10n.realUpper;

    final userLabel =
    record.userChoice == AnswerChoice.fake
        ? l10n.fakeUpper
        : l10n.realUpper;

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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(record.snippet),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: record.tags
                        .take(6)
                        .map((t) => Chip(label: Text(t)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: Icon(
                record.wasCorrect
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
              ),
              title: Text(l10n.caseReviewYourAnswer),
              subtitle: Text(userLabel),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: Text(l10n.caseReviewCorrectAnswer),
              subtitle: Text(correctLabel),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.caseReviewExplanation),
              subtitle: Text(record.explanation),
            ),
          ),
        ],
      ),
    );
  }
}
