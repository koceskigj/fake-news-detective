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

    // Build the streak chip once so we can measure/layout consistently.
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

    return AppBar(
      automaticallyImplyLeading: false,
      actions: const [],
      title: const SizedBox.shrink(),
      flexibleSpace: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {

            const double leftZoneWidth = 12 + 36 + 8; // left padding + logo + inner gap

            const double rightZoneWidth = 12 + 70; // right padding + approx chip width

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- CENTERED TEXT LOGO (true center of full AppBar width) ---
                  Center(
                    child: SizedBox(
                      height: 22,
                      child: Image.asset(
                        'assets/logo/logo_text.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // --- LEFT STOJCHE LOGO ---
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

                  // --- RIGHT STREAK CHIP ---
                  if (showDailyStreak)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: streakChip,
                      ),
                    ),

                  if (extraActions != null && extraActions!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        // push extra actions to the far right after streak chip space
                        padding: const EdgeInsets.only(right: rightZoneWidth),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: extraActions!,
                        ),
                      ),
                    ),

                  Positioned(
                    left: 0,
                    child: SizedBox(width: leftZoneWidth, height: 1),
                  ),
                  Positioned(
                    right: 0,
                    child: SizedBox(width: rightZoneWidth, height: 1),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
