import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

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

  // Anti-spam cooldown (seconds)
  int _cooldownLeft = 0;

  // UI state for the top header
  bool _showSuccessHeader = false;
  String? _statusMsg; // used for error message under button (optional)

  Future<void> _summonOne() async {
    if (_loading) return;
    if (_cooldownLeft > 0) return;

    setState(() {
      _loading = true;
      _statusMsg = null;
      _showSuccessHeader = false; // reset while generating
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

      if (created == 1) {
        setState(() {
          _showSuccessHeader = true;
          _statusMsg = null;
        });
      } else {
        // Duplicate filtered / no output
        setState(() {
          _showSuccessHeader = false;
          _statusMsg =
          'No case created this time (maybe duplicate filtered). Try again.';
        });
      }

      // Start cooldown
      setState(() => _cooldownLeft = 8);
      _tickCooldown();
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _showSuccessHeader = false;
        _statusMsg = 'Error: ${e.message ?? e.code}';
      });
    } catch (e) {
      setState(() {
        _showSuccessHeader = false;
        _statusMsg = 'Error: $e';
      });
    } finally {
      setState(() => _loading = false);
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
        // optional: clear message too
        _statusMsg = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canPress = !_loading && _cooldownLeft == 0;

    final headerText = _showSuccessHeader
        ? '✅ You successfully summoned an AI case!\nStudents can now play it.'
        : 'Summon a single AI case into the database.\n'
        'Students will see it and can solve it once.';

    final headerImage = _showSuccessHeader
        ? 'assets/stojche/stojche_correct.png' // celebration image
        : 'assets/stojche/stojche_talking.png'; // reading book image (make sure it exists)

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STOJCHE HEADER (like moderation screen) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset(
                    headerImage,
                    fit: BoxFit.contain,
                  ),
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

            // --- Controls ---
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'technology', child: Text('Technology')),
                DropdownMenuItem(value: 'health', child: Text('Health')),
                DropdownMenuItem(value: 'science', child: Text('Science')),
                DropdownMenuItem(value: 'sports', child: Text('Sports')),
                DropdownMenuItem(value: 'entertainment', child: Text('Entertainment')),
              ],
              onChanged: _loading ? null : (v) => setState(() => _category = v ?? 'technology'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 14),

            const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _difficulty,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 (Easy)')),
                DropdownMenuItem(value: 2, child: Text('2 (Medium)')),
                DropdownMenuItem(value: 3, child: Text('3 (Hard)')),
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
                      ? 'Summoning…'
                      : (_cooldownLeft > 0 ? 'Wait $_cooldownLeft s' : 'Summon 1 AI case'),
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
