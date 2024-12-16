import 'package:fairvest1/Users/login_page.dart';
import 'package:fairvest1/constants.dart';
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
      title: 'Sign-up Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SignUpAddressPage(),
    );
  }
}

class SignUpAddressPage extends StatefulWidget {
  const SignUpAddressPage({super.key});

  @override
  _SignUpAddressPageState createState() => _SignUpAddressPageState();
}

class _SignUpAddressPageState extends State<SignUpAddressPage> {
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();

  String selectedAddressType = 'Home';
  bool showModal = false;

  Future<void> _saveAddressDetails() async {
    // Collect address data
    final addressDetails = {
      "address": {
        "house": _houseController.text,
        "apartment": _apartmentController.text,
        "directions": _directionController.text,
      },
      "type": selectedAddressType,
    };

    print(addressDetails);
    try {
      // Make the POST request to your Flask backend
      final response = await http.post(
        Uri.parse('$baseUrl/buyers_sign3'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(addressDetails),
      );

      if (response.statusCode == 200) {
        // Show modal on success
        setState(() {
          showModal = true;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign-in Successful!'),
              content: const Center(
                child: Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-up Page'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Address Fields
            _buildTextField(_houseController, 'House/Flat/Block-No'),
            const SizedBox(height: 10),
            _buildTextField(_apartmentController, 'Apartment/Road'),
            const SizedBox(height: 10),
            _buildTextField(
                _directionController, 'Direction to reach the location'),
            const SizedBox(height: 20),

            // Address Type
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAddressTypeButton('Home', Icons.home),
                const SizedBox(width: 20),
                _buildAddressTypeButton('Office', Icons.work),
                const SizedBox(width: 20),
                _buildAddressTypeButton('Other', Icons.location_pin),
              ],
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _saveAddressDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.green[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAddressTypeButton(String type, IconData icon) {
    bool isSelected = type == selectedAddressType;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddressType = type;
        });
      },
      child: Column(
        children: [
          Icon(icon, size: 30, color: isSelected ? Colors.green : Colors.grey),
          const SizedBox(height: 5),
          Text(type,
              style: TextStyle(color: isSelected ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }
}
