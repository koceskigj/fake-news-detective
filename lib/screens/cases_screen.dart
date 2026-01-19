import 'dart:math';

import 'package:flutter/material.dart';

import '../models/answer_record.dart';
import '../models/case_item.dart';
import '../models/celebration_event.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/case_post_card.dart';
import '../widgets/celebration_dialog.dart';
import '../widgets/stojche_hint_area.dart';

enum UserChoice { real, fake }

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  List<CaseItem> _allCases = [];
  CaseItem? _current;

  UserChoice? _choice;
  bool? _isCorrect;

  // Celebrations queue
  final List<CelebrationEvent> _pendingCelebrations = [];

  // Repository load guard
  bool _loadedOnce = false;

  // Stojche hint state
  StojcheMood _stojcheMood = StojcheMood.idle;
  bool _hintUsed = false;
  String? _hintText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      _loadCases();
    }
  }

  Future<void> _loadCases() async {
    final appState = AppStateScope.of(context);

    final loaded = await appState.caseRepository.loadInitialCases();
    loaded.shuffle(Random());

    if (!mounted) return;

    setState(() {
      _allCases = loaded;
    });

    await _ensureCurrentCase();
  }

  List<CaseItem> _unsolvedCases(Set<String> solvedIds) {
    return _allCases.where((c) => !solvedIds.contains(c.id)).toList();
  }

  CaseItem? _pickNextCase({
    required List<CaseItem> unsolved,
    required int targetDifficulty,
  }) {
    final preferred = unsolved.where((c) => c.difficulty == targetDifficulty).toList();
    if (preferred.isNotEmpty) {
      preferred.shuffle(Random());
      return preferred.first;
    }

    List<int> fallback;
    if (targetDifficulty == 3) {
      fallback = [2, 1];
    } else if (targetDifficulty == 2) {
      fallback = [1, 3];
    } else {
      fallback = [2, 3];
    }

    for (final d in fallback) {
      final list = unsolved.where((c) => c.difficulty == d).toList();
      if (list.isNotEmpty) {
        list.shuffle(Random());
        return list.first;
      }
    }

    return null;
  }

  Future<void> _ensureCurrentCase() async {
    // still loading initial cases
    if (_loadedOnce && _allCases.isEmpty) return;

    final appState = AppStateScope.of(context);
    final progress = appState.progress;

    // Prefer built-in unsolved if any exist
    final unsolved = _unsolvedCases(progress.solvedCaseIds);

    CaseItem? nextItem;

    if (unsolved.isNotEmpty) {
      final target = appState.targetDifficultyFromStreak();
      nextItem = _pickNextCase(unsolved: unsolved, targetDifficulty: target);
    } else {
      // ✅ fallback to generated case (infinite)
      final target = appState.targetDifficultyFromStreak();
      nextItem = await appState.caseRepository.generateCase(
        progress: progress,
        targetDifficulty: target,
      );
    }

    if (!mounted) return;

    setState(() {
      _current = nextItem;
      _choice = null;
      _isCorrect = null;

      // Reset Stojche for new case
      _stojcheMood = StojcheMood.idle;
      _hintUsed = false;
      _hintText = null;
    });
  }

  String _generateHint(CaseItem item) {
    final tags = item.tags.map((t) => t.toLowerCase()).toList();

    String reason;
    if (tags.contains('clickbait') || tags.contains('sharebait')) {
      reason = 'This feels like clickbait: dramatic wording that tries to force a quick reaction.';
    } else if (tags.contains('missing-source') || tags.contains('vague-evidence')) {
      reason = 'I don’t see a credible source. “Experts say…” without names or links is suspicious.';
    } else if (tags.contains('fearbait') || tags.contains('urgent-language')) {
      reason = 'It uses urgency and fear to push you to act fast. Real info is usually calmer and specific.';
    } else if (tags.contains('context-missing') || tags.contains('cropped-clip')) {
      reason = 'This might be missing context. Short clips/screenshots can change the meaning.';
    } else if (tags.contains('absurd-claim') || tags.contains('too-good-to-be-true')) {
      reason = 'It sounds too good to be true. Extraordinary claims need strong evidence.';
    } else if (!item.isFake) {
      reason = 'This sounds specific and practical. That usually points toward real information.';
    } else {
      reason = 'Something feels off: vague details and no easy way to verify.';
    }

    final leaning = item.isFake ? 'I’m leaning towards FAKE.' : 'I’m leaning towards REAL.';
    return '$reason\n\n$leaning';
  }

  void _askStojche() {
    if (_current == null) return;
    if (_hintUsed) return;
    if (_choice != null) return;

    setState(() {
      _hintUsed = true;
      _stojcheMood = StojcheMood.talking;
      _hintText = _generateHint(_current!);
    });
  }

  Future<void> _answer(UserChoice choice) async {
    if (_choice != null) return;
    if (_current == null) return;

    final item = _current!;
    final pickedFake = (choice == UserChoice.fake);
    final correct = pickedFake == item.isFake;

    final appState = AppStateScope.of(context);

    final choiceEnum = pickedFake ? AnswerChoice.fake : AnswerChoice.real;

    // update mood for feedback
    final mood = correct ? StojcheMood.celebrate : StojcheMood.wise;

    final events = await appState.recordCaseSolved(
      caseId: item.id,
      userChoice: choiceEnum,
      isCorrect: correct,
      difficulty: item.difficulty,
      item: item,
      usedHint: _hintUsed,
    );

    if (!mounted) return;

    setState(() {
      _choice = choice;
      _isCorrect = correct;
      _pendingCelebrations.addAll(events);
      _stojcheMood = mood;
    });
  }

  Future<void> _showCelebrationsIfAny() async {
    while (_pendingCelebrations.isNotEmpty) {
      final ev = _pendingCelebrations.removeAt(0);

      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CelebrationDialog(event: ev),
      );

      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _next() async {
    if (_pendingCelebrations.isNotEmpty) {
      await _showCelebrationsIfAny();
    }
    if (!mounted) return;
    await _ensureCurrentCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appState = AppStateScope.of(context);
    final progress = appState.progress;

    // Loading initial cases from repo
    final isLoadingInitial = _loadedOnce && _allCases.isEmpty && _current == null;

    return Scaffold(
      appBar: const BrandedAppBar(), // branded, no screen title
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoadingInitial
              ? const Center(child: CircularProgressIndicator())
              : (_current == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Generating a new case…',
                style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
            ],
          )
              : Column(
            children: [
              // Case card
              CasePostCard(item: _current!),
              const SizedBox(height: 12),

              if (_choice == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _answer(UserChoice.real),
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('REAL'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _answer(UserChoice.fake),
                        icon: const Icon(Icons.report_gmailerrorred_outlined),
                        label: const Text('FAKE'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Session streak shown here (not in top bar)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Streak: ${appState.sessionStreak}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Level ${progress.level} • XP ${progress.xp}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Stojche hint area
                StojcheHintArea(
                  mood: _stojcheMood,
                  hintUsed: _hintUsed,
                  hintText: _hintText,
                  onAsk: _askStojche,
                ),
              ] else ...[
                // Feedback panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_isCorrect ?? false) ? cs.tertiaryContainer : cs.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_isCorrect ?? false) ? 'Correct ✅' : 'Not quite ❌',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: (_isCorrect ?? false)
                              ? cs.onTertiaryContainer
                              : cs.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _current!.explanation,
                        style: TextStyle(
                          height: 1.3,
                          color: (_isCorrect ?? false)
                              ? cs.onTertiaryContainer
                              : cs.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: _next,
                              child: Text(
                                _pendingCelebrations.isNotEmpty ? 'Claim rewards' : 'Next case',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // After answering, keep Stojche visible with a mood (no hint bubble needed)
                StojcheHintArea(
                  mood: _stojcheMood,
                  hintUsed: true,
                  hintText: null,
                  onAsk: () {},
                ),
              ],
            ],
          )),
        ),
      ),
    );
  }
}
