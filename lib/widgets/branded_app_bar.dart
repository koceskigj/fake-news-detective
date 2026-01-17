import 'package:flutter/material.dart';
import '../state/app_state_scope.dart';

class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDailyStreak;
  final List<Widget>? extraActions;

  const BrandedAppBar({
    super.key,
    this.showDailyStreak = true,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appState = AppStateScope.of(context);
    final daily = appState.progress.dailyStreak;

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          // Mascot/logo placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emoji_nature, // Stojche placeholder
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Fake News Detective',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
      actions: [
        if (showDailyStreak)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '📅 $daily',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ...?extraActions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
