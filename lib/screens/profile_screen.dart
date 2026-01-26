import 'package:fake_news_detective/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';
import 'onboarding/onboarding_flow.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Fake avatars (icon-based)
  static const List<_AvatarOption> _avatars = [
    _AvatarOption(keyName: 'monkey', label: 'Stojche', icon: Icons.emoji_nature),
    _AvatarOption(keyName: 'detective', label: 'Detective', icon: Icons.manage_search),
    _AvatarOption(keyName: 'owl', label: 'Owl', icon: Icons.visibility),
    _AvatarOption(keyName: 'robot', label: 'Robot', icon: Icons.smart_toy_outlined),
    _AvatarOption(keyName: 'fox', label: 'Fox', icon: Icons.pets_outlined),
    _AvatarOption(keyName: 'star', label: 'Star', icon: Icons.star_outline),
  ];

  IconData _iconForAvatarKey(String key) {
    return _avatars.firstWhere(
          (a) => a.keyName == key,
      orElse: () => _avatars.first,
    ).icon;
  }

  Future<void> _showUsernameSheet() async {
    final current = AppStateScope.of(context).progress.displayName;

    final String? newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final controller = TextEditingController(text: current);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change username',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'e.g., detective123',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(sheetContext, name); // return value
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Cancel'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          Navigator.pop(sheetContext, name); // return value
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // Sheet closed — now it’s safe to update state + save
    if (newName == null) return;

    final appState = AppStateScope.of(context);
    await appState.setDisplayName(newName);

    if (!mounted) return;
    setState(() {});
  }



  Future<void> _showAvatarSheet() async {
    final appState = AppStateScope.of(context);
    final currentKey = appState.progress.avatarKey;

    final String? selectedKey = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose avatar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _avatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (_, i) {
                  final a = _avatars[i];
                  final selected = a.keyName == currentKey;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(sheetContext, a.keyName),
                    child: Card(
                      child: Opacity(
                        opacity: selected ? 1.0 : 0.85,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                child: Icon(a.icon, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                a.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              if (selected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('Selected', style: TextStyle(fontSize: 11)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedKey == null) return;

    await appState.setAvatarKey(selectedKey);

    if (!mounted) return;
    setState(() {});
  }


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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
          (route) => false,
    );

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
      appBar: const BrandedAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 6),

            CircleAvatar(
              radius: 46,
              child: Icon(_iconForAvatarKey(p.avatarKey), size: 46),
            ),
            const SizedBox(height: 12),

            Text(
              p.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _StatChip(label: 'Level', value: '${p.level}'),
                _StatChip(label: 'XP', value: '${p.xp}'),
              ],
            ),

            const SizedBox(height: 18),

            Card(
              child: ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Change username'),
                subtitle: const Text('What should we call you?'),
                onTap: _showUsernameSheet,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.face_retouching_natural_outlined),
                title: const Text('Choose avatar'),
                subtitle: const Text('Pick your detective style'),
                onTap: _showAvatarSheet,
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
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Stats'),
                subtitle: const Text('All-time progress and records'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  );
                },
              ),
            ),

            const Spacer(),

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

class _AvatarOption {
  final String keyName;
  final String label;
  final IconData icon;

  const _AvatarOption({
    required this.keyName,
    required this.label,
    required this.icon,
  });
}
