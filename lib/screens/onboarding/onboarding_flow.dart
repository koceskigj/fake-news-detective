// lib/screens/onboarding/onboarding_flow.dart
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state_scope.dart';
import '../../app/home_shell.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  int _page = 0;

  final _nameController = TextEditingController();
  String _selectedAvatarKey = 'monkey';

  static const _avatars = [
    ('monkey', 'avatarStojche', Icons.emoji_nature),
    ('detective', 'avatarDetective', Icons.manage_search),
    ('owl', 'avatarOwl', Icons.visibility),
    ('robot', 'avatarRobot', Icons.smart_toy_outlined),
    ('fox', 'avatarFox', Icons.pets_outlined),
    ('star', 'avatarStar', Icons.star_outline),
    // Optional extra avatars (add keys in arb if you keep them)
    ('bolt', 'avatarBolt', Icons.bolt),
    ('shield', 'avatarShield', Icons.shield_outlined),
    ('leaf', 'avatarLeaf', Icons.eco_outlined),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finish() async {
    final appState = AppStateScope.of(context);
    await appState.completeOnboarding(
      displayName: _nameController.text,
      avatarKey: _selectedAvatarKey,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell(initialIndex: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Map avatar localization keys to actual localized strings
    String avatarLabel(String l10nKey) {
      switch (l10nKey) {
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

      // Optional extras (only if you add them to arb)
        case 'avatarBolt':
          return l10n.avatarBolt;
        case 'avatarShield':
          return l10n.avatarShield;
        case 'avatarLeaf':
          return l10n.avatarLeaf;

        default:
          return l10nKey; // shows missing keys
      }
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            // 1) Welcome
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Image.asset(
                      'assets/stojche/stojche_idle.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.onboardingWelcomeTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.onboardingWelcomeBody,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _next,
                    child: Text(l10n.continueBtn),
                  ),
                ],
              ),
            ),

            // 2) Username
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.onboardingUsernameTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.onboardingUsernameBody,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameController,
                    maxLength: 20,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.usernameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _next(),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _next,
                    child: Text(l10n.continueBtn),
                  ),
                ],
              ),
            ),

            // 3) Avatar selection
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    l10n.onboardingAvatarTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.onboardingAvatarBody,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _avatars.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, i) {
                        final (key, labelKey, icon) = _avatars[i];
                        final selected = key == _selectedAvatarKey;
                        final label = avatarLabel(labelKey);

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => _selectedAvatarKey = key),
                          child: Card(
                            color: selected ? cs.primaryContainer : null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  child: Icon(icon, size: 24),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _finish,
                      child: Text(l10n.continueBtn),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
