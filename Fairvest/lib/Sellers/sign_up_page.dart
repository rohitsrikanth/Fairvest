import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding
import 'package:fairvest1/sellers/sign_up_page_2.dart';
import 'login_page.dart';

class SellersSignUpPage extends StatefulWidget {
  const SellersSignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SellersSignUpPage> {
  final List<String> businessTypes = [
    "Farmer",
    "Food Mill Operator",
    "Pesticide and Crop Seller",
    "Wholesale Seller"
  ];

  String? selectedBusinessType;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController();

  String errorMessage = '';

  // POST request to backend API
  Future<void> submitForm() async {
    final Map<String, dynamic> sellerData = {
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "password": passwordController.text,
      "retype_password": retypePasswordController.text,
      "business_type": selectedBusinessType,
    };
    print(sellerData);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sellers_sign1'), // Use your backend URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(sellerData),
      );

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage2()),
        );
      } else {
        setState(() {
          errorMessage = json.decode(response.body)['error'] ?? 'Unknown error';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Sign-up Page',
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/fairvest_logo.png', // Replace with your image path
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome to Fairvest!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'Your trusted partner in transforming the agricultural marketplace!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Dropdown
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.green[100],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBusinessType,
                    hint: const Row(
                      children: [
                        Icon(Icons.storefront, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Select type of your Business'),
                      ],
                    ),
                    items: businessTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedBusinessType = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Input Fields
              buildTextField('Your Name', controller: nameController),
              buildTextField('Your Email (optional)',
                  controller: emailController),
              buildTextField('Your Phone Number', controller: phoneController),
              buildTextField('Password',
                  controller: passwordController, obscureText: true),
              buildTextField('Retype Password',
                  controller: retypePasswordController, obscureText: true),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              Center(
                child: ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const sLoginPage(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint,
      {TextEditingController? controller, bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.green[100],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
