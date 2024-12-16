import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Fairvest Centers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/farmer-management');
              },
              child: const Text('Manage Farmers'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/product-management');
              },
              child: const Text('Manage Products'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/order-management');
              },
              child: const Text('Manage Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
