import 'package:fairvest1/Users/home_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:fairvest1/sellers/profile_page.dart';
import 'package:flutter/material.dart';
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
      debugShowCheckedModeBanner: false,
      home: WholeSellesHomePage(),
    );
  }
}

class WholeSellesHomePage extends StatefulWidget {
  const WholeSellesHomePage({super.key});

  @override
  _WholeSellesHomePageState createState() => _WholeSellesHomePageState();
}

class _WholeSellesHomePageState extends State<WholeSellesHomePage> {
  Map<String, dynamic> userData = {};
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
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/fairvest_logo.png'),
          ),
        ),
        title: const Text('Fairvest'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FarmersProfilePage()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    'Welcome back, ${userData['name']}!\nHere\'s an overview of your business.',
                    style: const TextStyle(
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
                  const SizedBox(height: 10),
                  _buildCustomButton(
                    icon: Icons.shop_outlined,
                    label: 'Buy Now',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FairvestHomePage()),
                      );
                    },
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
