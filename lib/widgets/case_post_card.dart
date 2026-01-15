import 'package:flutter/material.dart';
import '../models/case_item.dart';

class CasePostCard extends StatelessWidget {
  final CaseItem item;

  const CasePostCard({super.key, required this.item});

  String _difficultyLabel(int d) {
    switch (d) {
      case 3:
        return 'Hard';
      case 2:
        return 'Medium';
      default:
        return 'Easy';
    }
  }

  IconData _difficultyIcon(int d) {
    switch (d) {
      case 3:
        return Icons.local_fire_department_outlined;
      case 2:
        return Icons.trending_up_outlined;
      default:
        return Icons.looks_one_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source + difficulty row
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.public, size: 18, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.sourceName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(_difficultyIcon(item.difficulty),
                          size: 14, color: cs.onSecondaryContainer),
                      const SizedBox(width: 6),
                      Text(
                        _difficultyLabel(item.difficulty),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (item.domainHint != null) ...[
              const SizedBox(height: 10),
              Text(
                'Domain: ${item.domainHint}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 14),

            Text(
              item.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              item.snippet,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
            const SizedBox(height: 14),

            if (item.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.tags.take(5).map((t) {
                  return Chip(
                    label: Text(t),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
