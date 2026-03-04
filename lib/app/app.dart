import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';
import '../models/user_progress.dart';
import '../services/local_storage.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';

import '../screens/onboarding/onboarding_flow.dart';
import '../screens/role_gate/role_gate_screen.dart';
import '../screens/teacher/teacher_login_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';


class FakeNewsDetectiveApp extends StatelessWidget {
  const FakeNewsDetectiveApp({super.key});

  Future<String> _ensureAuthAndGetUid() async {
    final auth = FirebaseAuth.instance;

    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }

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
    final uid = await _ensureAuthAndGetUid();

    final saved = await LocalStorage.loadProgressJson();
    if (saved != null) {
      var progress = UserProgress.fromJson(saved);

      if (progress.userId != uid) {
        progress = progress.copyWith(userId: uid);
        await LocalStorage.saveProgressJson(progress.toJson());
      }

      return AppState(progress: progress);
    }

    final progress = UserProgress(
      userId: uid,
      hasOnboarded: false,
      appMode: null,
      teacherUid: null,
      studentLocale: null,
      teacherLocale: null,
    );

    await LocalStorage.saveProgressJson(progress.toJson());
    return AppState(progress: progress);
  }

  Widget _errorScreen(Object? error) {
    String msg = error.toString();

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

        return AppStateScope(
          state: appState,
          child: Builder(
            builder: (context) {
              final state = AppStateScope.of(context);

              Widget home;
              if (state.progress.appMode == null) {
                home = const RoleGateScreen();
              } else if (state.progress.appMode == 'teacher') {
                home = const TeacherLoginScreen();
              } else {
                home = state.progress.hasOnboarded ? const HomeShell() : const OnboardingFlow();
              }

              return MaterialApp(
                title: 'Fake News Detective',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),

                locale: Locale(state.activeLocaleCode),

                supportedLocales: const [
                  Locale('en'),
                  Locale('mk'),
                ],

                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                home: home,
              );
            },
          ),
        );
      },
    );
  }
}
