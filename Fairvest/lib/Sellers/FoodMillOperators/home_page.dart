import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FoodMillOperatorPage(),
    );
  }
}

class FoodMillOperatorPage extends StatelessWidget {
  const FoodMillOperatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.access_time,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your logo image
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'Fairvest',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome Message
            const Text(
              '“Welcome back, [Mill Owner’s Name]! Here\'s an overview of your business.”',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),

            // Menu Items
            MenuItem(
              icon: Icons.bar_chart,
              label: 'Total sales',
              onTap: () {
                // Handle Total Sales Action
              },
            ),
            const SizedBox(height: 20),
            MenuItem(
              icon: Icons.pending,
              label: 'Pending orders',
              onTap: () {
                // Handle Pending Orders Action
              },
            ),
            const SizedBox(height: 20),
            MenuItem(
              icon: Icons.inventory,
              label: 'Inventory status',
              onTap: () {
                // Handle Inventory Status Action
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuItem({super.key, 
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}