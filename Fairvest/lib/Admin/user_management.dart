import 'package:fairvest1/Admin/order_analysis.dart';
import 'package:fairvest1/Admin/product_analysis.dart';
import 'package:fairvest1/Admin/user_management1.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GreenPage(),
    );
  }
}

class GreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E9),  // Light green background
      appBar: AppBar(
        title: Text('Fairvest Roles'),
        backgroundColor: Color(0xFF388E3C),  // Dark green header
      ),
      body: Padding(
        padding: const EdgeInsets.all(75.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF81C784),  // Medium green button
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  UsersPage(user : 'Farmer')),
                );},
              child: Text('Farmers'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF81C784),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  UsersPage(user : 'Pesticide and Crop Seller')),
                );},
              child: Text('Pesticides & Seed'),
            ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Color(0xFF81C784),
            //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            //     textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            //   onPressed: () {Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>  UsersPage(user : 'Food Mill Operator')),
            //     );},
            //   child: Text('Food Mill Operator'),
            //),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Color(0xFF81C784),
            //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            //     textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            //   onPressed: () {Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>  UsersPage(user : 'Wholesale Seller')),);
            //     },
            //   child: Text('Wholesale Seller'),
            // ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF81C784),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  UsersPage(user : 'Consumer')),
                );},
              child: Text('Consumer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF81C784),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  OrderAnalyticsApp(),));
                },
              child: Text('Order'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF81C784),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  ProductAnalysisApp(),));
                },
              child: Text('Products'),
            ),
          ],
        ),
      ),
    );
  }
}
