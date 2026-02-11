import 'package:flutter/material.dart';

import 'package:fake_news_detective/screens/stats_screen.dart';
import 'package:fake_news_detective/screens/student_settings_screen.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state_scope.dart';
import '../widgets/branded_app_bar.dart';
import '../screens/role_gate/role_gate_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<_AvatarOption> _avatars = [
    _AvatarOption(keyName: 'monkey', labelKey: 'avatarStojche', fallback: 'Stojche', icon: Icons.emoji_nature),
    _AvatarOption(keyName: 'detective', labelKey: 'avatarDetective', fallback: 'Detective', icon: Icons.manage_search),
    _AvatarOption(keyName: 'owl', labelKey: 'avatarOwl', fallback: 'Owl', icon: Icons.visibility),
    _AvatarOption(keyName: 'robot', labelKey: 'avatarRobot', fallback: 'Robot', icon: Icons.smart_toy_outlined),
    _AvatarOption(keyName: 'fox', labelKey: 'avatarFox', fallback: 'Fox', icon: Icons.pets_outlined),
    _AvatarOption(keyName: 'star', labelKey: 'avatarStar', fallback: 'Star', icon: Icons.star_outline),
  ];

  IconData _iconForAvatarKey(String key) {
    return _avatars.firstWhere(
          (a) => a.keyName == key,
      orElse: () => _avatars.first,
    ).icon;
  }

  String _avatarLabel(BuildContext context, _AvatarOption a) {
    final l10n = AppLocalizations.of(context)!;
    switch (a.labelKey) {
      case 'avatarStojche':
        return l10n.avatarStojche;
      case 'avatarDetective':
        return l10n.avatarDetective;
      case 'avatarOwl':
        return l10n.avatarOwl;
      case 'avatarRobot':
        return l10n.avatarRobot;
      case 'avatarFox':
        return l10n.avatarFox;
      case 'avatarStar':
        return l10n.avatarStar;
      default:
        return a.fallback;
    }
  }

  Future<void> _showUsernameSheet() async {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.changeUsername,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: l10n.usernameLabel,
                    hintText: l10n.usernameHint,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(sheetContext, name);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          Navigator.pop(sheetContext, name);
                        },
                        child: Text(l10n.save),
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

    if (newName == null) return;

    final appState = AppStateScope.of(context);
    await appState.setDisplayName(newName);

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showAvatarSheet() async {
    final l10n = AppLocalizations.of(context)!;
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.chooseAvatar,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                                _avatarLabel(context, a),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              if (selected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(l10n.selected, style: const TextStyle(fontSize: 11)),
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
    final l10n = AppLocalizations.of(context)!;
    final appState = AppStateScope.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.resetProgressTitle),
        content: Text(l10n.resetProgressBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await appState.resetProgress();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleGateScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = AppStateScope.of(context);
    final p = appState.progress;

    return Scaffold(
      appBar: BrandedAppBar(),
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
                _StatChip(label: l10n.level, value: '${p.level}'),
                _StatChip(label: l10n.xp, value: '${p.xp}'),
              ],
            ),

            const SizedBox(height: 18),

            Card(
              child: ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.changeUsername),
                subtitle: Text(l10n.changeUsernameSubtitle),
                onTap: _showUsernameSheet,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.face_retouching_natural_outlined),
                title: Text(l10n.chooseAvatar),
                subtitle: Text(l10n.chooseAvatarSubtitle),
                onTap: _showAvatarSheet,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.settings),
                subtitle: Text(l10n.settingsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentSettingsScreen()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: Text(l10n.stats),
                subtitle: Text(l10n.statsSubtitle),
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
                title: Text(l10n.resetProgressTitle),
                subtitle: Text(l10n.resetProgressSubtitle),
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
  final String labelKey;
  final String fallback;
  final IconData icon;

  const _AvatarOption({
    required this.keyName,
    required this.labelKey,
    required this.fallback,
    required this.icon,
  });
}
