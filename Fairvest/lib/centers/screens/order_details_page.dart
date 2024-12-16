import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order['id']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Product ID: ${order['productId']}',
                style: const TextStyle(fontSize: 16)),
            Text('Product Name: ${order['productName']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Farmer ID: ${order['farmerId']}',
                style: const TextStyle(fontSize: 16)),
            Text('Farmer Name: ${order['farmer']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Driver ID: ${order['driverId']}',
                style: const TextStyle(fontSize: 16)),
            Text('Driver Name: ${order['driverName']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            order['image'] != null
                ? Image.network(order['image'],
                    width: 150, height: 150, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 150),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // Live track logic
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Live Track'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
            ),
          ],
        ),
      ),
    );
  }
}
