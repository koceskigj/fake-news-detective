import 'package:flutter/material.dart';
import '../models/learn_pattern.dart';
import '../widgets/branded_app_bar.dart';

class PatternDetailScreen extends StatelessWidget {
  final LearnPattern pattern;

  const PatternDetailScreen({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            pattern.shortDescription,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(pattern.explanation, style: const TextStyle(height: 1.35)),
          const SizedBox(height: 16),
          const Text(
            'Quick checklist',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...pattern.checklist.map(
                (c) => Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
