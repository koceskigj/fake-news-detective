import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_news_detective/widgets/branded_app_bar.dart';
import 'package:flutter/material.dart';
import '../state/app_state_scope.dart';

class CreateCaseScreen extends StatefulWidget {
  const CreateCaseScreen({super.key});

  @override
  State<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _snippet = TextEditingController();
  final _sourceName = TextEditingController();
  final _sourceUrl = TextEditingController();
  final _explanation = TextEditingController();
  final _tags = TextEditingController();

  bool? _isFake; // must choose
  int _difficulty = 1;

  bool _sending = false;

  @override
  void dispose() {
    _title.dispose();
    _snippet.dispose();
    _sourceName.dispose();
    _sourceUrl.dispose();
    _explanation.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.toLowerCase())
        .toSet()
        .toList();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _title.clear();
    _snippet.clear();
    _sourceName.clear();
    _sourceUrl.clear();
    _explanation.clear();
    _tags.clear();
    setState(() {
      _isFake = null;
      _difficulty = 1;
    });
  }

  Future<void> _send() async {
    if (_sending) return;

    // 1) Validate fields
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isFake == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and choose REAL/FAKE.')),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final uid = AppStateScope.of(context).progress.userId;

      final doc = {
        'status': 'pending',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'title': _title.text.trim(),
        'snippet': _snippet.text.trim(),
        'sourceName': _sourceName.text.trim(),
        'sourceUrl': _sourceUrl.text.trim(),
        'isFake': _isFake,
        'explanation': _explanation.text.trim(),
        'difficulty': _difficulty,
        'tags': _parseTags(_tags.text),
      };

      await FirebaseFirestore.instance.collection('user_cases').add(doc);

      if (!mounted) return;

      // 2) Show Stojche popup
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Nice work, detective!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/stojche/stojche_correct.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your case was sent to the teachers for review. '
                    'Once approved, other students will be able to solve it.',
              ),
            ],
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      );

      // 3) Reset to empty
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send case: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Send a news case for teachers to review.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _title,
                  validator: _required,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _snippet,
                  validator: _required,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Snippet / short text',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sourceName,
                        validator: _required,
                        decoration: const InputDecoration(
                          labelText: 'Source name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _sourceUrl,
                        validator: _required,
                        decoration: const InputDecoration(
                          labelText: 'Source URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _explanation,
                  validator: _required,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Explanation (why REAL/FAKE)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _tags,
                  validator: _required,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    hintText: 'clickbait, missing-source, fearbait',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),

                // REAL/FAKE selector
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Correct answer',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('REAL'),
                              selected: _isFake == false,
                              onSelected: (_) => setState(() => _isFake = false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('FAKE'),
                              selected: _isFake == true,
                              onSelected: (_) => setState(() => _isFake = true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Difficulty
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Difficulty',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _difficulty,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 (Easy)')),
                          DropdownMenuItem(value: 2, child: Text('2 (Medium)')),
                          DropdownMenuItem(value: 3, child: Text('3 (Hard)')),
                        ],
                        onChanged: (v) => setState(() => _difficulty = v ?? 1),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                    label: Text(_sending ? 'Sending…' : 'Send case'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
