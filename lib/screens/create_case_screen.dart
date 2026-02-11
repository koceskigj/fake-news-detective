import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../l10n/app_localizations.dart';
import '../widgets/branded_app_bar.dart';

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

  bool? _isFake;
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

  String? _required(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if (v == null || v.trim().isEmpty) return l10n.required;
    return null;
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

  Future<User> _requireAuthedUser() async {
    final auth = FirebaseAuth.instance;

    // If not signed in, sign in anonymously
    if (auth.currentUser == null) {
      await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    }

    // Wait until FirebaseAuth announces a valid user/token
    final u = await auth.idTokenChanges().firstWhere((u) => u != null).timeout(
      const Duration(seconds: 10),
      onTimeout: () => auth.currentUser,
    );

    if (u == null) {
      throw Exception('Auth not ready. Please try again.');
    }

    // Small delay helps Firestore pick up the token on the write stream
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return u;
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    if (_sending) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isFake == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createCaseFillAllFields)),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final user = await _requireAuthedUser();
      final uid = user.uid;

      final doc = <String, dynamic>{
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

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(l10n.createCaseSuccessTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/stojche/stojche_correct.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(l10n.createCaseSuccessBody),
            ],
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.continueLabel),
              ),
            ),
          ],
        ),
      );

      _resetForm();
    } on FirebaseException catch (e) {
      if (!mounted) return;

      final msg = (e.code == 'permission-denied')
          ? l10n.createCasePermissionDenied
          : l10n.createCaseCouldNotSend(e.message ?? e.code);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createCaseCouldNotSend(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: BrandedAppBar(
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  l10n.createCaseIntro,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _title,
                  validator: _required,
                  decoration: InputDecoration(
                    labelText: l10n.createCaseFieldTitle,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _snippet,
                  validator: _required,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.createCaseFieldSnippet,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sourceName,
                        validator: _required,
                        decoration: InputDecoration(
                          labelText: l10n.createCaseFieldSourceName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _sourceUrl,
                        validator: _required,
                        decoration: InputDecoration(
                          labelText: l10n.createCaseFieldSourceUrl,
                          border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: l10n.createCaseFieldExplanation,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _tags,
                  validator: _required,
                  decoration: InputDecoration(
                    labelText: l10n.createCaseFieldTags,
                    hintText: l10n.createCaseTagsHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.createCaseCorrectAnswer,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Text(l10n.realUpper),
                              selected: _isFake == false,
                              onSelected: (_) => setState(() => _isFake = false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: Text(l10n.fakeUpper),
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

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.difficulty,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _difficulty,
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(l10n.difficultyEasy(1)),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(l10n.difficultyMedium(2)),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(l10n.difficultyHard(3)),
                          ),
                        ],
                        onChanged: (v) => setState(() => _difficulty = v ?? 1),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
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
                    label: Text(_sending ? l10n.sendingEllipsis : l10n.createCaseSendButton),
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
