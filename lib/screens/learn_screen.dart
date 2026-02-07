import 'package:flutter/material.dart';
import '../data/learn_patterns.dart';
import '../data/learn_tips.dart';
import '../widgets/branded_app_bar.dart';
import 'case_library_screen.dart';
import 'pattern_details_screen.dart';
import 'package:flutter/foundation.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  String tipOfTheDay() {
    final now = DateTime.now();
    // Simple deterministic daily index:
    final key = now.year * 10000 + now.month * 100 + now.day;
    return learnTips[key % learnTips.length];
  }

  @override
  Widget build(BuildContext context) {
    final tip = tipOfTheDay();

    return Scaffold(
      appBar: const BrandedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tip of the day
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tip of the day',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(tip, style: const TextStyle(height: 1.3)),
                ],
              ),
            ),
          ),


          const SizedBox(height: 14),

          // Learn patterns
          const Text(
            'Learn the patterns',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            itemCount: learnPatterns.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, i) {
              final p = learnPatterns[i];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatternDetailScreen(pattern: p),
                    ),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.psychology_outlined),
                        const SizedBox(height: 10),
                        Text(
                          p.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.shortDescription,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1.25),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Case library entry
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Case Library'),
              subtitle: const Text('Review solved cases and explanations'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CaseLibraryScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
