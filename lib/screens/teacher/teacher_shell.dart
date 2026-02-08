import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/branded_app_bar.dart';
import 'teacher_moderation_screen.dart';
import 'teacher_stats_screen.dart';
import 'teacher_tools_screen.dart';
import 'teacher_settings_screen.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int _index = 0;

  final _pages = const [
    TeacherModerationScreen(),
    TeacherStatsScreen(),
    TeacherToolsScreen(),
    TeacherSettingsScreen(),
  ];

  Stream<int> _pendingAssignedCountStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('user_cases')
        .where('assignedTo', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.size);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _pendingAssignedCountStream(),
      builder: (context, snap) {
        final pending = snap.data ?? 0;

        return Scaffold(
          appBar: BrandedAppBar(
            showDailyStreak: false,
            extraActions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$pending',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: _pages[_index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.rule), label: 'Moderate'),
              NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
              NavigationDestination(icon: Icon(Icons.auto_fix_high), label: 'AI Tools'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }
}
