import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/speech_bubble.dart';

class TeacherToolsScreen extends StatefulWidget {
  const TeacherToolsScreen({super.key});

  @override
  State<TeacherToolsScreen> createState() => _TeacherToolsScreenState();
}

class _TeacherToolsScreenState extends State<TeacherToolsScreen> {
  bool _loading = false;

  String _category = 'technology';
  int _difficulty = 2;

  int _cooldownLeft = 0;

  bool _showSuccessHeader = false;
  String? _statusMsg;

  Future<void> _summonOne() async {
    if (_loading) return;
    if (_cooldownLeft > 0) return;

    setState(() {
      _loading = true;
      _statusMsg = null;
      _showSuccessHeader = false;
    });

    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('generateAIBatch');

      final res = await fn.call({
        'count': 1,
        'category': _category,
        'difficulty': _difficulty,
      });

      final created = (res.data is Map && res.data['created'] != null)
          ? (res.data['created'] as num).toInt()
          : 0;

      final l10n = AppLocalizations.of(context)!;

      if (created == 1) {
        setState(() {
          _showSuccessHeader = true;
          _statusMsg = null;
        });
      } else {
        setState(() {
          _showSuccessHeader = false;
          _statusMsg = l10n.teacherToolsNoCaseCreated;
        });
      }

      setState(() => _cooldownLeft = 8);
      _tickCooldown();
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _showSuccessHeader = false;
        _statusMsg = l10n.teacherToolsError(e.message ?? e.code);
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _showSuccessHeader = false;
        _statusMsg = l10n.teacherToolsError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _tickCooldown() async {
    while (mounted && _cooldownLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _cooldownLeft--);
    }

    if (mounted) {
      setState(() {
        _showSuccessHeader = false;
        _statusMsg = null;
      });
    }
  }

  String _categoryLabel(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    switch (value) {
      case 'technology':
        return l10n.teacherToolsCategoryTechnology;
      case 'health':
        return l10n.teacherToolsCategoryHealth;
      case 'science':
        return l10n.teacherToolsCategoryScience;
      case 'sports':
        return l10n.teacherToolsCategorySports;
      case 'entertainment':
        return l10n.teacherToolsCategoryEntertainment;
      default:
        return value;
    }
  }

  String _difficultyLabel(BuildContext context, int value) {
    final l10n = AppLocalizations.of(context)!;
    switch (value) {
      case 1:
        return l10n.difficultyEasy(value);
      case 2:
        return l10n.difficultyMedium(value);
      case 3:
        return l10n.difficultyHard(value);
      default:
        return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final canPress = !_loading && _cooldownLeft == 0;

    final headerText = _showSuccessHeader
        ? l10n.teacherToolsHeaderSuccess
        : l10n.teacherToolsHeaderDefault;

    final headerImage = _showSuccessHeader
        ? 'assets/stojche/stojche_correct.png'
        : 'assets/stojche/stojche_talking.png';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset(headerImage, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SpeechBubble(
                    text: headerText,
                    backgroundColor: cs.secondaryContainer,
                    textColor: cs.onSecondaryContainer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(l10n.teacherToolsCategoryTitle,
                style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'technology', child: Text('technology')),
                DropdownMenuItem(value: 'health', child: Text('health')),
                DropdownMenuItem(value: 'science', child: Text('science')),
                DropdownMenuItem(value: 'sports', child: Text('sports')),
                DropdownMenuItem(value: 'entertainment', child: Text('entertainment')),
              ],
              selectedItemBuilder: (_) => [
                for (final v in const ['technology', 'health', 'science', 'sports', 'entertainment'])
                  Text(_categoryLabel(context, v)),
              ],
              onChanged: _loading ? null : (v) => setState(() => _category = v ?? 'technology'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 14),

            Text(l10n.teacherToolsDifficultyTitle,
                style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _difficulty,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              selectedItemBuilder: (_) => [
                Text(_difficultyLabel(context, 1)),
                Text(_difficultyLabel(context, 2)),
                Text(_difficultyLabel(context, 3)),
              ],
              onChanged: _loading ? null : (v) => setState(() => _difficulty = v ?? 2),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canPress ? _summonOne : null,
                icon: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _loading
                      ? l10n.teacherToolsSummoning
                      : (_cooldownLeft > 0
                      ? l10n.teacherToolsWaitSeconds(_cooldownLeft)
                      : l10n.teacherToolsSummonOne),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (_statusMsg != null)
              Text(
                _statusMsg!,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
