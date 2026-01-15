import 'package:flutter/material.dart';
import '../widgets/branded_app_bar.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Learn'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TipCard(
            title: 'Check the source',
            subtitle: 'Is it a trusted outlet? Look for “About” and contact info.',
          ),
          _TipCard(
            title: 'Watch emotional wording',
            subtitle: '“Shocking”, “they don’t want you to know”… often clickbait.',
          ),
          _TipCard(
            title: 'Look for evidence',
            subtitle: 'Credible claims cite experts, data, or official statements.',
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TipCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lightbulb_outline),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
