import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/local_storage.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    Future<void> choose(String mode) async {
      await LocalStorage.saveAppMode(mode);
      if (!context.mounted) return;
      // Restart routing by rebuilding root
      Navigator.of(context).pushReplacementNamed('/');
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.manage_search, size: 80, color: cs.primary),
              const SizedBox(height: 16),
              Text(
                l10n.roleSelectTitle,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.roleSelectSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => choose("student"),
                  child: Text(l10n.roleSelectContinueStudent),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => choose("teacher"),
                  child: Text(l10n.roleSelectContinueTeacher),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
