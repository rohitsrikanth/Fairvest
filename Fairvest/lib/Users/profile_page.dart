import 'dart:convert';
import 'package:fairvest1/Sellers/Farmers/chat_bot.dart';
import 'package:fairvest1/Users/cart_page.dart';
import 'package:fairvest1/Users/home_page.dart';
import 'package:fairvest1/Users/my_orders_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:fairvest1/widget/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getuser'));
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
            onPressed: () {},
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
                          '@${userData['username'] ?? 'NoUsername'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // User Details Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Section
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.green),
                          title: Text(userData['email'] ?? 'No Email'),
                        ),

                        // Address Section
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(children: [
                              Icon(Icons.local_shipping, color: Colors.green),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Get it in 1 day',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (userData['address'] != null)
                                    Text(
                                      'House No: ${userData['address']['house'] ?? 'N/A'}, '
                                      'Apartment: ${userData['address']['apartment'] ?? 'N/A'},\n'
                                      'Street: ${userData['address']['street'] ?? 'N/A'}, '
                                      'Directions: ${userData['address']['directions'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    )
                                  else
                                    const Text(
                                      'No Address Available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              )
                            ]))
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language, color: Colors.black),
                    title:
                        const Text('Language', style: TextStyle(fontSize: 18)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FairvestHomePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.shopping_bag, color: Colors.black),
                    title:
                        const Text('My Orders', style: TextStyle(fontSize: 18)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyOrdersPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.shopping_cart, color: Colors.black),
                    title: const Text('Cart', style: TextStyle(fontSize: 18)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.report_problem, color: Colors.black),
                    title: const Text('Raise a Complaint',
                        style: TextStyle(fontSize: 18)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    int _currentIndex = 1;

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
      ],
      currentIndex: _currentIndex,
      onTap: (index) {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const FairvestHomePage()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              break;
            case 2:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const CartPage()));
              break;
            case 3:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const CartPage()));
              break;
            case 4:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const DrawerMenuPage()));
              break;
            case 5:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => OpenUrlPage()));
              break;
          }
        }
      },
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
    );
  }
}
