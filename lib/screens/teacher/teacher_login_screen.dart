import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../state/app_state_scope.dart';
import '../role_gate/role_gate_screen.dart';
import 'teacher_shell.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<bool> _isTeacher(String uid) async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'teacher';
  }

  String _friendlyAuthError(Object e) {
    // Default message you asked for (custom, not raw Firebase text)
    const generic =
        'A teacher with these credentials does not exist. Try again.';

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return generic;
        case 'user-disabled':
          return 'This teacher account is disabled. Please contact the administrator.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a bit and try again.';
        default:
          return generic;
      }
    }

    return generic;
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login failed'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final email = _email.text.trim();
      final pass = _pass.text;

      if (email.isEmpty || pass.isEmpty) {
        await _showErrorDialog('Please enter both email and password.');
        return;
      }

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final uid = cred.user?.uid;
      if (uid == null) {
        await FirebaseAuth.instance.signOut();
        await _showErrorDialog(
          'A teacher with these credentials does not exist. Try again.',
        );
        return;
      }

      final teacher = await _isTeacher(uid);
      if (!teacher) {
        // IMPORTANT: sign out so teacher-only rules don't accidentally apply
        await FirebaseAuth.instance.signOut();
        await _showErrorDialog(
          'This account is not registered as a teacher.',
        );
        return;
      }

      // Save teacher mode into your local progress
      final appState = AppStateScope.of(context);
      await appState.setTeacherUid(uid);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TeacherShell()),
      );
    } catch (e) {
      await _showErrorDialog(_friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _backToRolePick() async {
    // If they got here, they picked teacher role already.
    // We want "Back" to CLEAR the role so RoleGate shows again.
    final appState = AppStateScope.of(context);
    await appState.clearRoleSelection();

    // Make sure teacher auth is not lingering
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleGateScreen()),
          (_) => false,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading ? null : _backToRolePick,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Login'),
              ),
            ),
            TextButton(
              onPressed: _loading ? null : _backToRolePick,
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
