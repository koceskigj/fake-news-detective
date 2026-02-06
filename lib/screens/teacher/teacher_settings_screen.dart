import 'package:flutter/material.dart';
import '../../state/app_state_scope.dart';
import '../role_gate/role_gate_screen.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final appState = AppStateScope.of(context);
    await appState.logoutTeacher(); // you must add this in AppState (I told you earlier)

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleGateScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                subtitle: const Text('Return to role selection'),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
