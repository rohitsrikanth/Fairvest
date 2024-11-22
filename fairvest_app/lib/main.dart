import 'package:fairvest_app/farmers_home_page.dart';
import 'package:flutter/material.dart';
import 'package:fairvest_app/login_page.dart';
import 'package:fairvest_app/sellers_login_page.dart';
import 'package:fairvest_app/mill_opearator_home_page.dart';
import 'package:fairvest_app/wholesellers_home_page.dart';
import 'package:fairvest_app/p_c_home_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fairvest',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FairvestScreen(),
      routes: {
        '/farmer': (context) => FarmersHomePage(),
        '/foodMillOperator': (context) => FoodMillOperatorPage(),
        '/pesticidesSeller': (context) => P_C_HomePage(),
        '/wholeSaleSellers': (context) => WholeSellesHomePage(),
      },
    );
  }
}

class FairvestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            color: Colors.green,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/fairvest_logo.png', // Add your logo image in assets
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Fairvest– Growing Connections,\nHarvesting Fairness.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Supply Chain Image Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(
                'assets/supply_chain.png', // Add your supply chain image in assets
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Sell and Buy Button Section
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.store, size: 50, color: Colors.green),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Sell button action
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage1()),
                              );
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'SELL',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.local_shipping, size: 50, color: Colors.green),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Use backgroundColor instead of primary
                            //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'BUY',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'To know more about who we are?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
