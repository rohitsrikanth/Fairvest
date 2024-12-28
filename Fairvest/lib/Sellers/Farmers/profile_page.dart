import 'package:fairvest1/Sellers/Farmers/prediction.dart';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'manage_orders.dart';
import 'package:fairvest1/Users/my_orders_page.dart';
import 'upload_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      home: FarmersProfilePage(),
    );
  }
}

class FarmersProfilePage extends StatefulWidget {
  const FarmersProfilePage({super.key});

  @override
  _FarmersProfilePageState createState() => _FarmersProfilePageState();
}

class _FarmersProfilePageState extends State<FarmersProfilePage> {
  late Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getuser1'));
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section
                  Container(
                    color: Colors.green[200],
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(userData[
                                  'profileImage'] ??
                              'https://via.placeholder.com/150'), // Default placeholder if no image
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData['name'] ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          '${userData['_id'] ?? 'NoUsername'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  // Menu Options for Farmers

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
                        MaterialPageRoute(
                            builder: (context) => const MyOrdersPage()),
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
                    icon: Icons.online_prediction_rounded,
                    label: 'Check Plant health',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImagePredictionPage()),
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
