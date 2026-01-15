import 'package:flutter/material.dart';
import '../widgets/branded_app_bar.dart';

class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Fake News Detective',
        actions: [
          IconButton(
            tooltip: 'Daily challenge (later)',
            onPressed: () {},
            icon: const Icon(Icons.local_fire_department_outlined),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today’s Case',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              'This tab will show a post card + REAL/FAKE buttons.\n'
                  'After answering, you’ll get feedback + an explanation.',
            ),
          ],
        ),
      ),
    );
  }
}
