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

    final List<AnswerRecord> visible =
    _mistakesOnly ? records.where((r) => !r.wasCorrect).toList() : records;

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent cases',
                    style: TextStyle(fontWeight: FontWeight.w800),
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

                  const correctBg = Color(0xFFE6F4EA);
                  const correctFg = Color(0xFF1E7F43);

                  const wrongBg = Color(0xFFFDEAEA);
                  const wrongFg = Color(0xFFB3261E);

                  final bgColor = r.wasCorrect ? correctBg : wrongBg;
                  final fgColor = r.wasCorrect ? correctFg : wrongFg;

                  final leadingIcon = r.wasCorrect
                      ? Icons.check_circle_outline
                      : Icons.error_outline;

                  final answerText =
                  r.userChoice == AnswerChoice.fake ? 'FAKE' : 'REAL';

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      color: bgColor,
                      child: ListTile(
                        leading: Icon(leadingIcon, color: fgColor),
                        title: Text(
                          r.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fgColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          '${r.sourceName} • $answerText • ${_fmtDate(r.answeredAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fgColor.withOpacity(0.9),
                          ),
                        ),
                        trailing:
                        Icon(Icons.chevron_right, color: fgColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CaseReviewScreen(record: r),
                            ),
                          );
                        },
                      ),
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
