import 'package:flutter/material.dart';
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
    TeacherSettingsScreen(), // ✅ new
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  }
}
