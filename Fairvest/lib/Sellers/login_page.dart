import 'package:fairvest1/Sellers/sign_up_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class sLoginPage extends StatefulWidget {
  const sLoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<sLoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> _login() async {
    String userId = _userIdController.text.trim();
    String password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("$baseUrl/sellers_login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "password": password}),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showMessage('Login successful');
        // Navigate based on role
        String role = responseData['data']['business_type'];
        if (role == 'Farmer') {
          Navigator.pushNamed(context, '/farmer');
        } else if (role == 'Food Mill Operator') {
          Navigator.pushNamed(context, '/foodMillOperator');
        } else if (role == 'Wholesale Seller') {
          Navigator.pushNamed(context, '/wholeSaleSellers');
        } else if (role == 'Pesticide and Crop Seller') {
          Navigator.pushNamed(context, '/pesticidesSeller');
        }
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage('Error: Unable to connect to the server');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.green,
              padding: const EdgeInsets.all(8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, color: Colors.white, size: 30),
                  SizedBox(width: 8),
                  Text(
                    'Login Page',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/fairvest_logo.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Fairvest – Growing Connections,\nHarvesting Fairness.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Please enter your User ID according to your role:\n'
                'FAR - Farmer\n'
                
                
                'PNC - Pesticide and Crop Seed Seller\n'
                'For example, if you are a Food Mill Operator, your User ID might look like FMO-JohnDoe.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),
            // Login Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      hintText: 'Enter User ID (e.g., FMO-JohnDoe)',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      hintText: 'Enter Password',
                      prefixIcon: const Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Forgot Password action
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text(
                      'GO',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Have you not registered yet?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SellersSignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Click here',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Footer Section
            Container(
              color: Colors.green,
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

