import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  static const Color _correctBg = Color(0xFFE6F4EA);
  static const Color _correctFg = Color(0xFF1E7F43);
  static const Color _wrongBg = Color(0xFFFDEAEA);
  static const Color _wrongFg = Color(0xFFB3261E);

  CaseItem? _current;

  UserChoice? _choice;
  bool? _isCorrect;

  final List<CelebrationEvent> _pendingCelebrations = [];

  bool _loadedOnce = false;
  bool _loadingCase = false;

  StojcheMood _stojcheMood = StojcheMood.idle;
  bool _hintUsed = false;
  String? _hintText;

  bool _answerSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      _ensureCurrentCase();
    }
  }

  /// ✅ Guarantee we have an authed user before ANY Firestore read.
  Future<User> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    final current = auth.currentUser;
    if (current != null) return current;

    final cred = await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    final u = cred.user;
    if (u == null) throw Exception('Anonymous sign-in failed.');
    return u;
  }

  Future<void> _ensureCurrentCase() async {
    if (_loadingCase) return;

    setState(() {
      _loadingCase = true;
      _choice = null;
      _isCorrect = null;
      _stojcheMood = StojcheMood.idle;
      _hintUsed = false;
      _hintText = null;
    });

    try {
      // ✅ make sure we are signed in before querying Firestore
      final user = await _ensureSignedIn();

      final appState = AppStateScope.of(context);

      // ✅ use FirebaseAuth uid for repo + solved list (avoids mismatch)
      final myUid = user.uid;

      final nextItem = await appState.caseRepository.getNextCase(
        myUid: myUid,
        solvedIds: appState.progress.solvedCaseIds,
      );

      if (!mounted) return;
      setState(() {
        _current = nextItem;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingCase = false);
      }
    }
  }

  String _generateHint(CaseItem item) {
    final tags = item.tags.map((t) => t.toLowerCase()).toList();

    String reason;
    if (tags.contains('clickbait') || tags.contains('sharebait')) {
      reason =
      'This feels like clickbait. The wording is emotional and tries to force a reaction.';
    } else if (tags.contains('missing-source') || tags.contains('vague-evidence')) {
      reason = 'I don’t see a clear source. “Experts say” without names is suspicious.';
    } else if (tags.contains('fearbait') || tags.contains('urgent-language')) {
      reason = 'It uses fear or urgency to push you to act fast. Real info is usually calmer.';
    } else if (tags.contains('context-missing') || tags.contains('cropped-clip')) {
      reason = 'This might be missing context. Short clips or screenshots can mislead.';
    } else if (tags.contains('absurd-claim') || tags.contains('too-good-to-be-true')) {
      reason = 'It sounds too good to be true. Extraordinary claims need strong evidence.';
    } else if (!item.isFake) {
      reason = 'This sounds specific and practical, which often points to real information.';
    } else {
      reason = 'Something feels off: vague details and no easy way to verify.';
    }

    final leaning = item.isFake ? 'I’m leaning towards FAKE.' : 'I’m leaning towards REAL.';
    return '$reason\n\n$leaning';
  }

  void _askStojche() {
    if (_current == null || _hintUsed || _choice != null) return;
    setState(() {
      _hintUsed = true;
      _stojcheMood = StojcheMood.talking;
      _hintText = _generateHint(_current!);
    });
  }

  Future<void> _answer(UserChoice choice) async {
    if (_choice != null || _current == null) return;
    if (_answerSubmitting) return;

    setState(() => _answerSubmitting = true);

    try {
      final item = _current!;
      final pickedFake = (choice == UserChoice.fake);
      final correct = pickedFake == item.isFake;

      final appState = AppStateScope.of(context);
      final choiceEnum = pickedFake ? AnswerChoice.fake : AnswerChoice.real;

      final mood = correct ? StojcheMood.celebrate : StojcheMood.wise;

      final events = await appState.recordCaseSolved(
        caseId: item.id,
        userChoice: choiceEnum,
        isCorrect: correct,
        difficulty: item.difficulty,
        usedHint: _hintUsed,
        item: item,
      );

      if (!mounted) return;

      setState(() {
        _choice = choice;
        _isCorrect = correct;
        _pendingCelebrations.addAll(events);
        _stojcheMood = mood;
      });
    } finally {
      if (mounted) setState(() => _answerSubmitting = false);
    }
  }

  Future<void> _showCelebrationsIfAny() async {
    while (_pendingCelebrations.isNotEmpty) {
      final ev = _pendingCelebrations.removeAt(0);
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
    if (_pendingCelebrations.isNotEmpty) await _showCelebrationsIfAny();
    if (!mounted) return;
    await _ensureCurrentCase();
  }

  @override
  Widget build(BuildContext context) {
    final isFirstLoadSpinner = !_loadedOnce || (_loadingCase && _current == null);

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isFirstLoadSpinner
              ? const Center(child: CircularProgressIndicator())
              : (_current == null
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Image.asset(
                    'assets/stojche/stojche_idle.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "You’ve solved all available cases.\nCome back later!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _loadingCase ? null : _ensureCurrentCase,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          )
              : ListView(
            children: [
              CasePostCard(item: _current!),
              const SizedBox(height: 12),
              if (_choice == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _answerSubmitting ? null : () => _answer(UserChoice.real),
                        style: FilledButton.styleFrom(
                          backgroundColor: _correctBg,
                          foregroundColor: _correctFg,
                        ),
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('REAL'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _answerSubmitting ? null : () => _answer(UserChoice.fake),
                        style: FilledButton.styleFrom(
                          backgroundColor: _wrongBg,
                          foregroundColor: _wrongFg,
                        ),
                        icon: const Icon(Icons.report_gmailerrorred_outlined),
                        label: const Text('FAKE'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StojcheHintArea(
                  mood: _stojcheMood,
                  hintUsed: _hintUsed,
                  hintText: _hintText,
                  onAsk: _askStojche,
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_isCorrect ?? false) ? _correctBg : _wrongBg,
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
                          color: (_isCorrect ?? false) ? _correctFg : _wrongFg,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _current!.explanation,
                        style: TextStyle(
                          color: (_isCorrect ?? false) ? _correctFg : _wrongFg,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _next,
                        child: Text(
                          _pendingCelebrations.isNotEmpty ? 'Claim rewards' : 'Next case',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
