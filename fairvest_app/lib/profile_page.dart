import 'package:fairvest_app/blog_page_1.dart';
import 'package:fairvest_app/cart_page.dart';
import 'package:fairvest_app/home_page.dart';
import 'package:fairvest_app/my_orders_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(

        child: Column(
          children: [
            // Profile Section

            Container(

              color: Colors.green[200],
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with your image
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 15,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Muthu',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '@Muthu31',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Location and Delivery Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.green),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get it in 1 day',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Kalyanpur, Kanpur'),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            // Menu Options
            ListTile(
              leading: Icon(Icons.language, color: Colors.black),
              title: Text('Language', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FairvestHomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.black),
              title: Text('My Orders', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyOrdersPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.black),
              title: Text('Cart', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.article, color: Colors.black),
              title: Text('Blog', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlogPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.report_problem, color: Colors.black),
              title: Text('Raise a Complaint', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
