import 'package:flutter/material.dart';
import 'revenue_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomerDetailsScreen(),
    );
  }
}

class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Replace with the Fairvest logo path
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              'Fairvest',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RevenuePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer name and date range
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Customer / Connie Robertson",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "Jan 01 - Jan 28",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Profile card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile picture and name
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150', // Replace with the actual profile image URL
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Connie Robertson",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "victoriasimmons@2020.com",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 30),
                      // Details
                      buildInfoRow(Icons.folder, "Group", "9,520"),
                      buildInfoRow(Icons.location_on, "Location",
                          "Undefined, Minnesota 40 United States."),
                      buildInfoRow(Icons.date_range, "First Order",
                          "September 30, 2019 1:49 PM"),
                      buildInfoRow(Icons.date_range, "Latest Orders",
                          "February 14, 2020 7:52 AM"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Revenue and other stats
              buildStatCard("Revenue", "\$75,620", "+ 22%", Colors.orange),
              buildStatCard("Orders Paid", "500", "+ 5.7%", Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatCard(
      String title, String value, String percentage, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  percentage,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.show_chart,
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
