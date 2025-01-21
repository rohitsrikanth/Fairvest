import 'dart:convert'; // For JSON decoding
import 'package:fairvest1/Sellers/P&C/current_orders.dart';
import 'package:fairvest1/Sellers/manage_orders.dart';
import 'package:fairvest1/Sellers/profile_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: P_C_HomePage(),
    );
  }
}

class P_C_HomePage extends StatefulWidget {
  const P_C_HomePage({super.key});

  @override
  _P_C_HomePageState createState() => _P_C_HomePageState();
}

class _P_C_HomePageState extends State<P_C_HomePage> {
  bool isLoading = true;
  Map<String, dynamic> userData = {};

  // Base URL for the API request
  // Replace with your actual base URL

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
        print(userData);
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
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
            backgroundImage: AssetImage(
                'assets/fairvest_logo.png'), // Replace with your logo
          ),
        ),
        title: const Text('Fairvest'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmersProfilePage(),
                ),
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
                ? const CircularProgressIndicator() // Show loading indicator while fetching data
                : Text(
                    'Welcome back, ${userData['name']}! \nHere\'s an overview of your business.',
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
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MyOrdersApp()));
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildCustomButton(
                    icon: Icons.inventory,
                    label: 'Inventory Status',
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FarmersManageOrders()));
                    },
                  ),
                  const SizedBox(height: 10),
                  // _buildCustomButton(
                  //   icon: Icons.group,
                  //   label: 'Supplier activity',
                  //   onPressed: () {},
                  // ),
                  // const SizedBox(height: 10),
                  // _buildCustomButton(
                  //   icon: Icons.schedule,
                  //   label: 'Production schedule',
                  //   onPressed: () {},
                  // ),
                  // const SizedBox(height: 10),
                  // _buildCustomButton(
                  //   icon: Icons.bar_chart,
                  //   label: 'Revenue summary',
                  //   onPressed: () {},
                  // ),
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
          borderRadius: BorderRadius.circular(16),
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
