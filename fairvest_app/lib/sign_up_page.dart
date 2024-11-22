import 'package:flutter/material.dart';
import 'package:fairvest_app/login_page.dart';
import 'package:fairvest_app/sign_up_page_2.dart';

void main() {
  runApp(SignUpApp());
}

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Colors.green,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.storefront, color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Sign-up Page',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Enter Details',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/fairvest_logo.png', // Replace with your image asset
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to Fairvest!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Your trusted partner in transforming the agricultural marketplace!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.brown),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Create Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    buildTextField('Your Name'),
                    SizedBox(height: 10),
                    buildTextField('Your Email'),
                    SizedBox(height: 10),
                    buildTextField('Your Phone Number'),
                    SizedBox(height: 10),
                    buildTextField('Password', obscureText: true),
                    SizedBox(height: 10),
                    buildTextField('Retype Password', obscureText: true),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to registration page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage2()),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      // Navigate to login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );

                    },
                    child: Text(
                      "Click here",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.green.shade300,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
