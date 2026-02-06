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

  Future<String> _ensureAuthedUid() async {
    final auth = FirebaseAuth.instance;

    // ✅ Important for Chrome/web so UID survives refresh/restart
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }

    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }

    return auth.currentUser!.uid;
  }

  Future<AppState> _init() async {
    // 1) Ensure Firebase auth exists (anonymous by default).
    final uid = await _ensureAuthedUid();

    // 2) Load local progress.
    final saved = await LocalStorage.loadProgressJson();

    if (saved != null) {
      var progress = UserProgress.fromJson(saved);

      // 3) MIGRATION (student only):
      // Make sure the leaderboard doc id matches request.auth.uid
      // so Firestore rules allow write.
      final isStudentOrUnset =
      (progress.appMode == null || progress.appMode == 'student');

      if (isStudentOrUnset && progress.userId != uid) {
        progress = progress.copyWith(userId: uid);
        await LocalStorage.saveProgressJson(progress.toJson());
      }

      return AppState(progress: progress);
    }

    // 4) First launch: create progress and show RoleGate first
    final progress = UserProgress(
      userId: uid,
      hasOnboarded: false,
      appMode: null, // <-- RoleGate first time
      teacherUid: null,
    );

    // Save immediately so refresh/hot restart doesn't create "new user progress"
    await LocalStorage.saveProgressJson(progress.toJson());

    return AppState(progress: progress);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _init(),
      builder: (context, snap) {
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

        // 1) Role not selected yet
        if (appState.progress.appMode == null) {
          home = const RoleGateScreen();

          // 2) Teacher route
        } else if (appState.progress.appMode == 'teacher') {
          home = const TeacherLoginScreen();

          // 3) Student route
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
