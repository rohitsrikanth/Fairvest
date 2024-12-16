import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports and Analytics'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Sales Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Export logic
              },
              child: const Text('Export Report'),
            ),
          ],
        ),
      ),
    );
  }
}
