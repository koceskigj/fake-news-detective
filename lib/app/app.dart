import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import 'home_shell.dart';
import '../models/user_progress.dart';
import '../services/local_storage.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';

import '../screens/onboarding/onboarding_flow.dart';
import '../screens/role_gate/role_gate_screen.dart';
import '../screens/teacher/teacher_login_screen.dart';

class FakeNewsDetectiveApp extends StatelessWidget {
  const FakeNewsDetectiveApp({super.key});

  Future<String> _ensureAuthAndGetUid() async {
    final auth = FirebaseAuth.instance;

    // ✅ IMPORTANT for Chrome/Edge:
    // Persist auth locally so the same anonymous user survives refresh / reruns.
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }

    // If nobody is signed in, sign in anonymously (students).
    if (auth.currentUser == null) {
      await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    }

    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Auth failed: no Firebase user after sign-in.');
    }

    return user.uid;
  }

  Future<AppState> _init() async {
    // 1) Ensure we have a Firebase UID (anonymous by default).
    final uid = await _ensureAuthAndGetUid();

    // 2) Load local progress (if it exists).
    final saved = await LocalStorage.loadProgressJson();
    if (saved != null) {
      var progress = UserProgress.fromJson(saved);

      // 3) Migration: align stored userId with Firebase uid (needed for Firestore rules).
      if (progress.userId != uid) {
        progress = progress.copyWith(userId: uid);
        await LocalStorage.saveProgressJson(progress.toJson());
      }

      return AppState(progress: progress);
    }

    // 4) First run: create progress, show role gate.
    final progress = UserProgress(
      userId: uid,
      hasOnboarded: false,
      appMode: null, // show RoleGate first
      teacherUid: null,
    );

    await LocalStorage.saveProgressJson(progress.toJson());
    return AppState(progress: progress);
  }

  Widget _errorScreen(Object? error) {
    String msg = error.toString();

    // Make the common Firebase auth errors more human-friendly
    if (msg.contains('operation-not-allowed') || msg.contains('OPERATION_NOT_ALLOWED')) {
      msg =
      'Anonymous auth is not enabled in Firebase.\n\n'
          'Fix: Firebase Console → Authentication → Sign-in method → Enable Anonymous.\n\n'
          'Then run again.';
    } else if (msg.contains('network-request-failed')) {
      msg =
      'Network error while signing in.\n\n'
          'Check internet, emulator network, or browser extensions/adblock.\n'
          'Then run again.';
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'App failed to start:\n\n$msg',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _init(),
      builder: (context, snap) {
        if (snap.hasError) return _errorScreen(snap.error);

        if (!snap.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final appState = snap.data!;
        Widget home;

        if (appState.progress.appMode == null) {
          home = const RoleGateScreen();
        } else if (appState.progress.appMode == 'teacher') {
          home = const TeacherLoginScreen();
        } else {
          home = appState.progress.hasOnboarded
              ? const HomeShell()
              : const OnboardingFlow();
        }

        return AppStateScope(
          state: appState,
          child: MaterialApp(
            title: 'Fake News Detective',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: home,
          ),
        );
      },
    );
  }
}
