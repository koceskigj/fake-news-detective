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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appState = AppStateScope.of(context);
    final daily = appState.progress.dailyStreak;

    final Widget streakChip = Container(
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
    );

    final bool hasExtra = extraActions != null && extraActions!.isNotEmpty;

    return AppBar(
      automaticallyImplyLeading: false,
      actions: const [],
      title: const SizedBox.shrink(),
      flexibleSpace: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 22,
                child: Image.asset(
                  'assets/logo/logo_text.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // LEFT MONKEY
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(
                    'assets/logo/stojche_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // RIGHT SIDE
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showDailyStreak) streakChip,
                    if (hasExtra) ...extraActions!,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
