import 'package:flutter/material.dart';

void main() {
  runApp(const ManageOrdersApp());
}

class ManageOrdersApp extends StatelessWidget {
  const ManageOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FarmersManageOrders(),
    );
  }
}

class FarmersManageOrders extends StatelessWidget {
  final List<OrderItem> orders = const [
    OrderItem(
      imageUrl: 'assets/tomatoes.jpg',
      title: 'Tomatoes',
      subtitle: 'Fresh tomatoes from the farm',
      units: '10 kg',
    ),
    OrderItem(
      imageUrl: 'assets/beans.jpg',
      title: 'Beans',
      subtitle: 'High-quality beans',
      units: '20 kg',
    ),
    OrderItem(
      imageUrl: 'assets/rice.jpg',
      title: 'Rice',
      subtitle: 'Organic long-grain rice',
      units: '50 kg',
    ),
  ];

  const FarmersManageOrders({super.key});

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
      body: ListView.builder(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                order.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
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
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Action for Accept button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Accept'),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    // Action for Reject button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String units;

  const OrderItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.units,
  });
}
