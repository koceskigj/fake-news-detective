import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class TeacherToolsScreen extends StatefulWidget {
  const TeacherToolsScreen({super.key});

  @override
  State<TeacherToolsScreen> createState() => _TeacherToolsScreenState();
}

class _TeacherToolsScreenState extends State<TeacherToolsScreen> {
  bool _loading = false;
  String? _msg;

  Future<void> _generate100() async {
    setState(() {
      _loading = true;
      _msg = null;
    });

    try {
      final fn = FirebaseFunctions.instance.httpsCallable('generateAIBatch');
      final res = await fn.call({'count': 100, 'category': 'technology', 'difficulty': 2});
      setState(() => _msg = 'Created: ${res.data['created']} AI cases ✅');
    } catch (e) {
      setState(() => _msg = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Generate AI cases into ai_cases collection.\nTeachers should not spam this.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _generate100,
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Generate 100 AI cases'),
              ),
            ),
            const SizedBox(height: 12),
            if (_msg != null) Text(_msg!),
          ],
        ),
      ),
    );
  }
}
