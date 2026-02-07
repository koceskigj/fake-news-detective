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

  Future<String> _ensureAnonAuthAndGetUid() async {
    final auth = FirebaseAuth.instance;

    // If nobody is signed in, sign in anonymously (students).
    if (auth.currentUser == null) {
      await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    }

    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Auth failed: no Firebase user after anonymous sign-in.');
    }

    return user.uid;
  }

  Future<AppState> _init() async {
    // Ensure UID (with timeout)
    final uid = await _ensureAnonAuthAndGetUid();

    // Load local progress
    final saved = await LocalStorage.loadProgressJson();
    if (saved != null) {
      var progress = UserProgress.fromJson(saved);

      // Migration: align stored userId with Firebase uid
      if (progress.userId != uid) {
        progress = progress.copyWith(userId: uid);
        await LocalStorage.saveProgressJson(progress.toJson());
      }

      return AppState(progress: progress);
    }

    // First run
    final progress = UserProgress(
      userId: uid,
      hasOnboarded: false,
      appMode: null, // show role gate first
      teacherUid: null,
    );

    await LocalStorage.saveProgressJson(progress.toJson());
    return AppState(progress: progress);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _init(),
      builder: (context, snap) {
        if (snap.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'App failed to start:\n\n${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

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
