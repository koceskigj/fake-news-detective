import 'package:flutter/material.dart';
import '../widgets/branded_app_bar.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Rewards'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.bolt),
                title: const Text('Level 1'),
                subtitle: const Text('XP: 0 / 100'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(9, (i) {
                  final unlocked = i < 2;
                  return Opacity(
                    opacity: unlocked ? 1.0 : 0.4,
                    child: Card(
                      child: Center(
                        child: Icon(
                          unlocked ? Icons.emoji_events_outlined : Icons.lock_outline,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
