import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'teacher';
  }

  String _friendlyAuthError(Object e) {
    final l10n = AppLocalizations.of(context)!;

    // default message
    final generic = l10n.teacherLoginErrGeneric;

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return generic;
        case 'user-disabled':
          return l10n.teacherLoginErrDisabled;
        case 'network-request-failed':
          return l10n.teacherLoginErrNetwork;
        case 'too-many-requests':
          return l10n.teacherLoginErrTooMany;
        default:
          return generic;
      }
    }

    return generic;
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.teacherLoginFailedTitle),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final l10n = AppLocalizations.of(context)!;

      final email = _email.text.trim();
      final pass = _pass.text;

      if (email.isEmpty || pass.isEmpty) {
        await _showErrorDialog(l10n.teacherLoginErrEnterBoth);
        return;
      }

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final uid = cred.user?.uid;
      if (uid == null) {
        await FirebaseAuth.instance.signOut();
        await _showErrorDialog(l10n.teacherLoginErrGeneric);
        return;
      }

      final teacher = await _isTeacher(uid);
      if (!teacher) {
        await FirebaseAuth.instance.signOut();
        await _showErrorDialog(l10n.teacherLoginErrNotTeacher);
        return;
      }

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
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    final appState = AppStateScope.of(context);
    await appState.logoutTeacher();

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teacherLoginTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading ? null : _backToRolePick,
          tooltip: l10n.back,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: l10n.email),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pass,
              decoration: InputDecoration(labelText: l10n.password),
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
                    : Text(l10n.login),
              ),
            ),
            TextButton(
              onPressed: _loading ? null : _backToRolePick,
              child: Text(l10n.back),
            ),
          ],
        ),
      ),
    );
  }
}
