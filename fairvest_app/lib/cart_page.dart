import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CartPage(),
    );
  }
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Cart"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          _buildDeliveryAddress(),
          _buildDeliveryInfo("Delivery 1", [
            _buildProductCard("Onion - Organically Grown", "1kg", 102.04, 431.51, "assets/oni.jpg"),
            _buildProductCard("Tomato - Local", "1kg", 44.63, 67.53, "assets/tomato.png"),
          ]),
          _buildDeliveryInfo("Delivery 2", [
            _buildProductCard("Ponni Raw Rice", "26kg", 1673.07, 2600.0, "assets/rice.jpg"),
          ]),
          //const Divider(thickness: 1.0),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensures minimal height
          children: [
            _buildSummary(),
            const SizedBox(height: 10),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Deliver to Home",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "10/42, 1st floor, C3, Subramaniyan Nagar, Chennai - 600024",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(String deliveryTitle, List<Widget> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            deliveryTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...products,
      ],
    );
  }

  Widget _buildProductCard(String name, String weight, double price, double originalPrice, String imagePath) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$weight • ₹$price"),
            Text("₹$originalPrice", style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.remove, color: Colors.green), onPressed: () {}),
            Text("1"),
            IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: () {}),
          ],
        ),
      ),
    );
  }
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          icon: const Icon(Icons.flash_on),
          label: const Text("Get it now"),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
          ),
          icon: const Icon(Icons.schedule, color: Colors.black),
          label: const Text("Schedule delivery", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}

Widget _buildSummary() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Total:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "₹1819.74",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          "Saved ₹969.30",
          style: TextStyle(color: Colors.green, fontSize: 14),
        ),
      ],
    ),
  );
}
