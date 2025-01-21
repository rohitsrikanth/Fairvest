import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyOrdersApp());
}

class MyOrdersApp extends StatelessWidget {
  const MyOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyOrdersPage(),
    );
  }
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders data from the backend API
  Future<void> _fetchOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/get_orders'));

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
      print(orders);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("My Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
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
            child: orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(
  order['date'] ?? "Unknown Date",
  order['time'] ?? "Unknown Time",
  order['logoPath'] ?? "assets/default_logo.png",
);

                    },
                  ),
          ),

          // Footer Section
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[200],
            child: const Column(
              children: [
                Text(
                  "Write to us at customerservice@Fairvest.com",
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
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

  Widget _buildOrderCard(String date, String time, String logoPath) {
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
      ),
    );
  }
}
