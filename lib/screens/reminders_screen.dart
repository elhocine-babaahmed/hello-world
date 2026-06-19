import 'package:flutter/material.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 56, color: Color(0xFFD8C8AC)),
            SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3A2A18)),
            ),
            SizedBox(height: 6),
            Text(
              'Reminders appear here once you log a "next action" date',
              style: TextStyle(fontSize: 13, color: Color(0xFF8C7257)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}