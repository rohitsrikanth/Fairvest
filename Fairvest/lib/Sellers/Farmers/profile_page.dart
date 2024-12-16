import 'package:flutter/material.dart';
import 'manage_orders.dart';
import 'package:fairvest1/Users/my_orders_page.dart';
import 'upload_page.dart';
import 'package:fairvest1/blog_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const FarmersProfilePage(),
    );
  }
}

class FarmersProfilePage extends StatelessWidget {
  const FarmersProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/profile_placeholder.png'),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 15,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 15),
                          onPressed: () {
                            // Action to update profile picture
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Farmer Name',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '@Farmer123',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Location and Delivery Information
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather in my area',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Kalyanpur, Kanpur'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // Menu Options for Farmers
            _buildMenuOption(
              context,
              icon: Icons.language,
              label: 'Language',
              onTap: () {
                // Action for Language menu
              },
            ),
            _buildMenuOption(
              context,
              icon: Icons.inventory,
              label: 'Manage Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FarmersManageOrders()),
                );
              },
            ),
            _buildMenuOption(
              context,
              icon: Icons.shopping_bag,
              label: 'My Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                );
              },
            ),
            _buildMenuOption(
              context,
              icon: Icons.add_circle_outline,
              label: 'Post Your Product',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadProductApp()),
                );
              },
            ),
            _buildMenuOption(
              context,
              icon: Icons.cloud,
              label: 'Weather in My Area',
              onTap: () {
                Navigator.pushNamed(context, '/weatherhome');
              },
            ),
            _buildMenuOption(
              context,
              icon: Icons.article,
              label: 'Blog',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlogPage()),
                );
              },
            ),
            _buildMenuOption(
              context,
              icon: Icons.report_problem,
              label: 'Raise a Complaint',
              onTap: () {
                // Action for raising a complaint
              },
            ),
            _buildMenuOption(
              context,
              icon: Icons.star,
              label: 'FV Score',
              onTap: () {
                // Action for FV Score
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
