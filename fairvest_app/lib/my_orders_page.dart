import 'package:fairvest_app/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyOrdersApp());
}

class MyOrdersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyOrdersPage(),
    );
  }
}

class MyOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("My Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

          },
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green[100],
              border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Image.asset(
                    'assets/fairvest_logo.png', // Replace with your asset path
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Faivest",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Past Orders Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                const Text(
                  "Past Orders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildOrderCard(
                  "Tue, 29 Oct 2024",
                  "07:00 PM - 08:00 PM",
                  "assets/fairvest_logo.png", // Replace with your asset path
                  "assets/oni.jpg", // Replace with your asset path
                ),
                _buildOrderCard(
                  "Mon, 16 Sep 2024",
                  "05:00 PM - 08:00 PM",
                  "assets/fairvest_logo.png",
                  "assets/fruits.png",
                ),
                _buildOrderCard(
                  "Fri, 19 Jul 2024",
                  "05:00 PM - 08:00 PM",
                  "assets/fairvest_logo.png",
                  "assets/rice.jpg",
                ),
              ],
            ),
          ),

          // Footer Section
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[200],
            child: Column(
              children: [
                const Text(
                  "Write to us at customerservice@bigbasket.com",
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
                const SizedBox(height: 5),
                const Text(
                  "for help with other previous orders.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String date, String time, String logoPath, String productImagePath) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: Image.asset(
          logoPath,
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivered $date",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              "Arrived between $time",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Image.asset(
                productImagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
