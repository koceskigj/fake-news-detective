import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/speech_bubble.dart';

class TeacherStatsScreen extends StatelessWidget {
  const TeacherStatsScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    return FirebaseFirestore.instance
        .collection('answer_events')
        .orderBy('answeredAt', descending: true)
        .limit(2000)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _stream(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text(l10n.teacherStatsError('${snap.error}')));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  l10n.teacherStatsEmpty,
                  textAlign: TextAlign.center,
                ),
              );
            }

            int night = 0, morning = 0, afternoon = 0, evening = 0;

            for (final d in docs) {
              final bucket = (d.data()['bucket'] ?? '').toString();
              switch (bucket) {
                case 'night':
                  night++;
                  break;
                case 'morning':
                  morning++;
                  break;
                case 'afternoon':
                  afternoon++;
                  break;
                case 'evening':
                  evening++;
                  break;
              }
            }

            final total = night + morning + afternoon + evening;

            double frac(int v) => total == 0 ? 0 : (v / total);

            String pctText(int v) =>
                total == 0 ? '0.0%' : '${(v * 100.0 / total).toStringAsFixed(1)}%';

            Widget statBar({
              required String label,
              required String subtitle,
              required int value,
              required double fraction,
            }) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            Container(color: cs.surfaceContainerHighest),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
                              duration: const Duration(milliseconds: 550),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) {
                                return FractionallySizedBox(
                                  widthFactor: v,
                                  alignment: Alignment.centerLeft,
                                  child: Container(color: cs.primary),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.teacherStatsAnswersCount(value),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          pctText(value),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset(
                        'assets/stojche/stojche_talking.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SpeechBubble(
                        text: l10n.teacherStatsHeaderBubble,
                        backgroundColor: cs.secondaryContainer,
                        textColor: cs.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  l10n.teacherStatsTotalAnswers(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                statBar(
                  label: l10n.teacherStatsNight,
                  subtitle: l10n.teacherStatsNightTime,
                  value: night,
                  fraction: frac(night),
                ),
                statBar(
                  label: l10n.teacherStatsMorning,
                  subtitle: l10n.teacherStatsMorningTime,
                  value: morning,
                  fraction: frac(morning),
                ),
                statBar(
                  label: l10n.teacherStatsAfternoon,
                  subtitle: l10n.teacherStatsAfternoonTime,
                  value: afternoon,
                  fraction: frac(afternoon),
                ),
                statBar(
                  label: l10n.teacherStatsEvening,
                  subtitle: l10n.teacherStatsEveningTime,
                  value: evening,
                  fraction: frac(evening),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.teacherStatsTip(total),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
