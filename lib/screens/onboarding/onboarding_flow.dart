import 'package:flutter/material.dart';
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
    ('monkey', 'Stojche', Icons.emoji_nature),
    ('detective', 'Detective', Icons.manage_search),
    ('owl', 'Owl', Icons.visibility),
    ('robot', 'Robot', Icons.smart_toy_outlined),
    ('fox', 'Fox', Icons.pets_outlined),
    ('star', 'Star', Icons.star_outline),
    ('bolt', 'Bolt', Icons.bolt),
    ('shield', 'Shield', Icons.shield_outlined),
    ('leaf', 'Leaf', Icons.eco_outlined),
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

    // Go to Profile tab
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell(initialIndex: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                  const Text(
                    'Welcome, detective!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hi there! I’m Stojche, a fake news detective, but truth be told, just your average Prilep resident. I’ll help you spot fake news using clues and logic. Let the fun begin!',
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
                    child: const Text('Continue'),
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
                  const Text(
                    'Enter your username',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This name will show on your profile and leaderboard.',
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
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _next(),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _next,
                    child: const Text('Continue'),
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
                  const Text(
                    'Choose your avatar',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You can change this later in Profile.',
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
                        final (key, label, icon) = _avatars[i];
                        final selected = key == _selectedAvatarKey;

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
                      child: const Text('Continue'),
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
