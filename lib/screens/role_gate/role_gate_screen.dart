import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state_scope.dart';
import '../onboarding/onboarding_flow.dart';
import '../teacher/teacher_login_screen.dart';

class RoleGateScreen extends StatelessWidget {
  final bool forceTeacher;
  const RoleGateScreen({super.key, this.forceTeacher = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.roleGateTitle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.roleGateSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          title: l10n.roleStudentTitle,
                          subtitle: l10n.roleStudentSubtitle,
                          icon: Icons.school_outlined,
                          onTap: forceTeacher
                              ? null
                              : () async {
                            final appState =
                            AppStateScope.of(context);
                            await appState.setAppModeStudent();

                            if (!context.mounted) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const OnboardingFlow()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleCard(
                          title: l10n.roleTeacherTitle,
                          subtitle: l10n.roleTeacherSubtitle,
                          icon: Icons.admin_panel_settings_outlined,
                          onTap: () async {
                            final appState =
                            AppStateScope.of(context);
                            await appState.setAppModeTeacher();

                            if (!context.mounted) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const TeacherLoginScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Text(
                    forceTeacher
                        ? l10n.roleGateTeacherForced
                        : l10n.roleGateHint,
                    style: TextStyle(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: disabled ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cs.primaryContainer,
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
