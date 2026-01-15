import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';
import '../models/user_progress.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';

class FakeNewsDetectiveApp extends StatelessWidget {
  const FakeNewsDetectiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState(
      progress: UserProgress(userId: 'local-demo-user'),
    );

    return AppStateScope(
      state: appState,
      child: MaterialApp(
        title: 'Fake News Detective',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeShell(),
      ),
    );
  }
}
