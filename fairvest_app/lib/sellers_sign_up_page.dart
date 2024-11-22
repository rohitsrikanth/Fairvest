import 'package:fairvest_app/sellers_login_page.dart'; // Ensure this file exists and has SellersLoginPage
import 'package:fairvest_app/sellers_sign_up_page_2.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(SignUpApp());
}

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SellersSignUpPage(),
    );
  }
}

class SellersSignUpPage extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
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
                    SizedBox(height: 10),
                    Text(
                      'Welcome to Fairvest!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'your trusted partner in transforming the agricultural marketplace!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              // Dropdown
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.green[100],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBusinessType,
                    hint: Row(
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
              SizedBox(height: 15),
              // Input Fields
              buildTextField('Your Name'),
              buildTextField('Your Email (optional)'),
              buildTextField('Your Phone Number'),
              buildTextField('Password', obscureText: true),
              buildTextField('Retype Password', obscureText: true),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Next button pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SellersSignUpPage2()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        // Navigate to the login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage1(),
                          ),
                        );
                      },
                      child: Text(
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

  Widget buildTextField(String hint, {bool obscureText = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.green[100],
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
