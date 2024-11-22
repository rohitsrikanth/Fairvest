import 'package:fairvest_app/sellers_sign_up_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage1(),
    );
  }
}

class LoginPage1 extends StatefulWidget {
  @override
  _LoginPage1State createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Define prefixes for user IDs
  final Map<String, String> _prefixRoutes = {
    'FMO-': '/foodMillOperator',
    'FAR-': '/farmer',
    'PCS-': '/pesticidesSeller',
    'WHS-': '/wholeSaleSellers',
  };

  void _login() {
    String userId = _userIdController.text.trim();
    String password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      _showMessage('Please enter both User ID and Password.');
      return;
    }

    // Check the prefix of the User ID and navigate to the corresponding page
    String? route;
    _prefixRoutes.forEach((prefix, routeName) {
      if (userId.startsWith(prefix)) {
        route = routeName;
        print(route);
      }
    });

    if (route != null) {
      Navigator.pushNamed(context, route!);
    } else {
      _showMessage('Invalid User ID. Please check your credentials.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.green,
                  padding: EdgeInsets.all(8),
                  child: Row(
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
                SizedBox(height: 20),
                Image.asset(
                  'assets/fairvest_logo.png', // Placeholder for the image
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Fairvest– Growing Connections,\nHarvesting Fairness.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.green[200],
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    hintText: 'Enter User ID (e.g., FMO-12345)',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.green[200],
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    hintText: 'Enter Password',
                    prefixIcon: Icon(Icons.vpn_key),
                    suffixIcon: Icon(Icons.visibility_off),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot Password action
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _login,
                  child: Text(
                    'GO',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Have you not registered yet?'),
                    TextButton(
                      onPressed: () {
                        // Registration action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SellersSignUpPage()),
                          );

                      },
                      child: Text(
                        'Click here',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  color: Colors.green,
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
