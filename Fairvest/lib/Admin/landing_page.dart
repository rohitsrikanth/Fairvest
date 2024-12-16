import 'package:flutter/material.dart';
import 'recent_part.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Add menu action here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RecentPurchasesScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/logo.png', // Replace with your logo image
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'Fairvest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card for Active Orders
            OrderCard(
              title: 'Active Orders',
              value: '₹126.500',
              percentage: '34.7%',
              subtitle: 'Compared to Oct 2023',
              icon: Icons.shopping_bag_outlined,
            ),
            SizedBox(height: 16),
            // Card for Completed Orders
            OrderCard(
              title: 'Completed Orders',
              value: '₹126.500',
              percentage: '34.7%',
              subtitle: 'Compared to Oct 2023',
              icon: Icons.shopping_bag_outlined,
            ),
            SizedBox(height: 16),
            // Card for Return Orders
            OrderCard(
              title: 'Return Orders',
              value: '₹126.500',
              percentage: '34.7%',
              subtitle: 'Compared to Oct 2023',
              icon: Icons.shopping_bag_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final String subtitle;
  final IconData icon;

  const OrderCard({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00344D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: Colors.green,
                          size: 16,
                        ),
                        Text(
                          percentage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // Add menu action here
            },
          ),
        ],
      ),
    );
  }
}
