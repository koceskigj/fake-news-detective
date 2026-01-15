import 'package:flutter/material.dart';
import '../widgets/branded_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 42,
              child: Icon(Icons.person, size: 42),
            ),
            const SizedBox(height: 12),
            const Text(
              'Guest Detective',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.face_retouching_natural_outlined),
                title: const Text('Choose avatar'),
                subtitle: const Text('Pick a style for your detective'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme'),
                subtitle: const Text('Light / Dark (later)'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                subtitle: const Text('Language, sound, reset progress (later)'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
