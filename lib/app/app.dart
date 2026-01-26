import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../theme/app_theme.dart';
import 'home_shell.dart';
import '../models/user_progress.dart';
import '../services/local_storage.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';

class FakeNewsDetectiveApp extends StatelessWidget {
  const FakeNewsDetectiveApp({super.key});

  Future<AppState> _init() async {
    final saved = await LocalStorage.loadProgressJson();

    if (saved != null) {
      final progress = UserProgress.fromJson(saved);
      return AppState(progress: progress);
    }

    final newId = const Uuid().v4();
    final progress = UserProgress(userId: newId);

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

        return AppStateScope(
          state: snap.data!,
          child: MaterialApp(
            title: 'Fake News Detective',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: const HomeShell(),
          ),
        );
      },
    );
  }
}
