import 'package:flutter/material.dart';

void main() {
  runApp(ManageOrdersApp());
}

class ManageOrdersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FarmersManageOrders(),
    );
  }
}

class FarmersManageOrders extends StatelessWidget {
  final List<OrderItem> orders = [
    OrderItem(
      imageUrl: 'assets/tomatoes.jpg',
      title: 'Lorem',
      subtitle: 'Lorem ipsum',
      units: '1 unit',
    ),
    OrderItem(
      imageUrl: 'assets/beans.jpg',
      title: 'Lorem',
      subtitle: 'Lorem ipsum',
      units: '1 unit',
    ),
    OrderItem(
      imageUrl: 'assets/rice.jpg',
      title: 'Lorem',
      subtitle: 'Lorem ipsum',
      units: '1 unit',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Icon(Icons.list_alt, size: 30),
            SizedBox(width: 10),
            Text('Manage orders'),
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

  const OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Accept'),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                  child: Text('Reject'),
                ),
              ],
            )
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

  OrderItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.units,
  });
}
