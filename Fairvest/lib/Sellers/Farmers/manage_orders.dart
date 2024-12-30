import 'dart:convert';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ManageOrdersApp());
}

class ManageOrdersApp extends StatelessWidget {
  const ManageOrdersApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FarmersManageOrders(),
    );
  }
}

class FarmersManageOrders extends StatefulWidget {
  const FarmersManageOrders({Key? key}) : super(key: key);

  @override
  _FarmersManageOrdersState createState() => _FarmersManageOrdersState();
}

class _FarmersManageOrdersState extends State<FarmersManageOrders> {
  List<OrderItem> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse('$baseUrl/manage-products');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          orders = data.map((item) => OrderItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Row(
          children: [
            Icon(Icons.list_alt, size: 30),
            SizedBox(width: 10),
            Text('Manage Orders'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(order: order);
              },
            ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderItem order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              IntrinsicWidth(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    order.imageUrl,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.subtitle,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      order.units,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
              // Column(
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         // Action for Accept button
              //       },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.green,
              //       ),
              //       child: const Text('Accept'),
              //     ),
              //     const SizedBox(height: 5),
              //     ElevatedButton(
              //       onPressed: () {
              //         // Action for Reject button
              //       },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.brown,
              //       ),
              //       child: const Text('Reject'),
              //     ),
              //   ],
              // ),
            ],
          )),
    );
  }
}

class OrderItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String units;

  OrderItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.units,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['imageUrl'];
    if (!imageUrl.startsWith('http')) {
      imageUrl = '$imageUrl';
    }
    return OrderItem(
      imageUrl: imageUrl,
      title: json['title'],
      subtitle: json['subtitle'],
      units: json['units'],
    );
  }
}
