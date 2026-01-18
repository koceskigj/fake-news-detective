import 'package:flutter/material.dart';

import '../models/answer_record.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';
import 'case_review_screen.dart';

class CaseLibraryScreen extends StatefulWidget {
  const CaseLibraryScreen({super.key});

  @override
  State<CaseLibraryScreen> createState() => _CaseLibraryScreenState();
}

class _CaseLibraryScreenState extends State<CaseLibraryScreen> {
  bool _mistakesOnly = false;

  String _fmtDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final progress = appState.progress;

    // newest first
    final List<AnswerRecord> records = progress.recentAnswers.reversed.toList();

    final List<AnswerRecord> visible = _mistakesOnly
        ? records.where((r) => !r.wasCorrect).toList()
        : records;

    return Scaffold(
      appBar: const BrandedAppBar(showDailyStreak: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _mistakesOnly
                        ? 'Mistakes (last ${progress.recentAnswers.length})'
                        : 'Recent cases (last ${progress.recentAnswers.length})',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                FilterChip(
                  label: const Text('Mistakes only'),
                  selected: _mistakesOnly,
                  onSelected: (v) => setState(() => _mistakesOnly = v),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: visible.isEmpty
                  ? const Center(
                child: Text(
                  'Nothing to review yet.\nPlay some cases first.',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.separated(
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final r = visible[i];

                  final leadingIcon = r.wasCorrect
                      ? Icons.check_circle_outline
                      : Icons.error_outline;

                  final answerText = r.userChoice == AnswerChoice.fake ? 'FAKE' : 'REAL';

                  return Card(
                    child: ListTile(
                      leading: Icon(leadingIcon),
                      title: Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${r.sourceName} • $answerText • ${_fmtDate(r.answeredAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaseReviewScreen(record: r),
                          ),
                        );
                      },
                    ),
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
