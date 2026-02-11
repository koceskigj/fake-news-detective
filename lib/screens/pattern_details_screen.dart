import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../models/learn_pattern.dart';
import '../widgets/branded_app_bar.dart';

class PatternDetailScreen extends StatelessWidget {
  final LearnPattern pattern;

  const PatternDetailScreen({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final shortDesc = l10n.byKey(pattern.shortDescription);
    final expl = l10n.byKey(pattern.explanation);

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title (optional but nice)
          Text(
            l10n.byKey(pattern.title),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          Text(
            shortDesc,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          Text(
            expl,
            style: const TextStyle(height: 1.35),
          ),

          const SizedBox(height: 16),
          Text(
            l10n.patternQuickChecklist,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),

          ...pattern.checklist.map((keyOrText) {
            final text = l10n.byKey(keyOrText);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(text),
              ),
            );
          }),
        ],
      ),
    );
  }
}
