import 'package:fairvest_app/blog_page_1.dart';
import 'package:fairvest_app/farmers_manage_orders.dart';
import 'package:fairvest_app/my_orders_page.dart';
import 'package:fairvest_app/upload_poduct.dart';
import 'package:flutter/material.dart';
import 'package:fairvest_app/Weather_home_page.dart';

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
      home: FarmersProfilePage(),
    );
  }
}

class FarmersProfilePage extends StatelessWidget {
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
              color: Colors.green,
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
                    'Farmer Name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '@Farmer123',
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
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather in my area',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Kalyanpur, Kanpur'),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            // Menu Options for Farmers
            ListTile(
              leading: Icon(Icons.language, color: Colors.black),
              title: Text('Language', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: Colors.black),
              title: Text('Manage Orders', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FarmersManageOrders(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.black),
              title: Text('My Orders', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrdersPage()),
              );},
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: Colors.black),
              title: Text('Post your product', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadProductApp()),
              );},
            ),
            ListTile(
              leading: Icon(Icons.cloud, color: Colors.black),
              title: Text('Weather in my area', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherScreen()),);},
            ),
            ListTile(
              leading: Icon(Icons.article, color: Colors.black),
              title: Text('Blog', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlogPage()),
              );},
            ),
            ListTile(
              leading: Icon(Icons.report_problem, color: Colors.black),
              title: Text('Raise a Complaint', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.black),
              title: Text('FV Score', style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
