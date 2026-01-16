import 'package:flutter/material.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _confirmAndReset(BuildContext context) async {
    final appState = AppStateScope.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'This will erase your XP, levels, achievements, streaks, and case history on this device.\n\nYou can’t undo this.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await appState.resetProgress();

    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress reset ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final p = appState.progress;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 6),

            // Mascot / Avatar placeholder
            CircleAvatar(
              radius: 46,
              child: Icon(Icons.emoji_nature, size: 46), // Stojche placeholder
            ),
            const SizedBox(height: 12),

            const Text(
              'Guest Detective',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),

            // Quick stats row
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _StatChip(label: 'Level', value: '${p.level}'),
                _StatChip(label: 'XP', value: '${p.xp}'),
                _StatChip(label: 'Daily 🔥', value: '${p.dailyStreak}'),
                _StatChip(label: 'Session 🔥', value: '${p.sessionStreak}'),
              ],
            ),

            const SizedBox(height: 18),

            // Future items
            Card(
              child: ListTile(
                leading: const Icon(Icons.face_retouching_natural_outlined),
                title: const Text('Choose avatar'),
                subtitle: const Text('Coming soon (Stojche upgrades)'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar selection coming soon ✅')),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Nickname'),
                subtitle: const Text('Coming soon'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nickname coming soon ✅')),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                subtitle: const Text('Language, sound, etc. (later)'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon ✅')),
                  );
                },
              ),
            ),

            const Spacer(),

            // Reset progress
            Card(
              child: ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset progress'),
                subtitle: const Text('Start over on this device'),
                onTap: () => _confirmAndReset(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: cs.onSecondaryContainer,
        ),
      ),
    );
  }
}
