import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../theme/app_theme.dart';
import 'home_shell.dart';
import '../models/user_progress.dart';
import '../services/local_storage.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';
import '../screens/onboarding/onboarding_flow.dart';

class FakeNewsDetectiveApp extends StatelessWidget {
  const FakeNewsDetectiveApp({super.key});

  Future<AppState> _init() async {
    final saved = await LocalStorage.loadProgressJson();

    if (saved != null) {
      final progress = UserProgress.fromJson(saved);
      return AppState(progress: progress);
    }

    // First app launch → generate user
    final newId = const Uuid().v4();
    final progress = UserProgress(
      userId: newId,
      hasOnboarded: false,
    );

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

        return AppStateScope(
          state: appState,
          child: MaterialApp(
            title: 'Fake News Detective',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),

            /// 👇 Onboarding decision
            home: appState.progress.hasOnboarded
                ? const HomeShell()
                : const OnboardingFlow(),
          ),
        );
      },
    );
  }
}
