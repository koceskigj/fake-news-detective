import 'dart:math';

import 'package:flutter/material.dart';

import '../models/answer_record.dart';
import '../models/case_item.dart';
import '../models/celebration_event.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/case_post_card.dart';
import '../widgets/celebration_dialog.dart';

enum UserChoice { real, fake }

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  // ✅ no longer late/final: loaded async from repository
  List<CaseItem> _allCases = [];

  CaseItem? _current;

  UserChoice? _choice;
  bool? _isCorrect;

  final List<CelebrationEvent> _pendingCelebrations = [];

  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ safe place to use AppStateScope.of(context)
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

    _ensureCurrentCase();
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

  void _ensureCurrentCase() {
    if (_allCases.isEmpty) return; // still loading

    final appState = AppStateScope.of(context);
    final progress = appState.progress;

    final unsolved = _unsolvedCases(progress.solvedCaseIds);
    if (unsolved.isEmpty) {
      final target = appState.targetDifficultyFromStreak();
      appState.caseRepository
          .generateCase(progress: progress, targetDifficulty: target)
          .then((gen) {
        if (!mounted) return;
        setState(() {
          _current = gen; // may be null if repo can't generate
          _choice = null;
          _isCorrect = null;
        });
      });
      return;
    }


    final target = appState.targetDifficultyFromStreak();
    final picked = _pickNextCase(unsolved: unsolved, targetDifficulty: target);

    setState(() {
      _current = picked;
      _choice = null;
      _isCorrect = null;
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

    final events = await appState.recordCaseSolved(
      caseId: item.id,
      userChoice: choiceEnum,
      isCorrect: correct,
      difficulty: item.difficulty,
    );

    if (!mounted) return;

    setState(() {
      _choice = choice;
      _isCorrect = correct;
      _pendingCelebrations.addAll(events);
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
    _ensureCurrentCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appState = AppStateScope.of(context);
    final progress = appState.progress;

    final isLoading = _allCases.isEmpty;

    if (isLoading) {
      return Scaffold(
        appBar: const BrandedAppBar(),

        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final unsolvedCount = _unsolvedCases(progress.solvedCaseIds).length;

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _current == null
              ? Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 44),
                    const SizedBox(height: 10),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 10),
                    const Text(
                      'Next step: AI-generated cases will enable unlimited new training posts.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Later: AI will generate unlimited cases ✅'),
                          ),
                        );
                      },
                      child: const Text('About AI cases'),
                    ),
                  ],
                ),
              ),
            ),
          )
              : Column(
            children: [
              Row(
                children: [
                  Text(
                    'New cases left: $unsolvedCount',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _allCases.isEmpty ? 0 : (1 - (unsolvedCount / _allCases.length)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

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
                const SizedBox(height: 8),
                Text(
                  'Tip: check the source, domain, and emotional language.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ] else ...[
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
