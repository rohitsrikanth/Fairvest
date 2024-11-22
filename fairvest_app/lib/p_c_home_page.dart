import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: P_C_HomePage(),
    );
  }
}

class P_C_HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/logo.png'), // Replace with your logo
          ),
        ),
        title: const Text('Fairvest'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '"Welcome back, [Pesticide Shop Owner’s Name]!\nHere\'s an overview of your business."',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCustomButton(
                    icon: Icons.shopping_cart,
                    label: 'Current Orders',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildCustomButton(
                    icon: Icons.inventory,
                    label: 'Inventory Status',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildCustomButton(
                    icon: Icons.group,
                    label: 'Supplier activity',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildCustomButton(
                    icon: Icons.schedule,
                    label: 'Production schedule',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  _buildCustomButton(
                    icon: Icons.bar_chart,
                    label: 'Revenue summary',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }
}
