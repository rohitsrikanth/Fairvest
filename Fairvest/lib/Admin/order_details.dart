import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrderDetailsScreen(),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Fairvest",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Orders ID: #6743",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date Range
            Text(
              "Feb 16, 2022 - Feb 20, 2022",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Change Status and Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: "Change Status",
                  items: const [
                    DropdownMenuItem(
                      value: "Change Status",
                      child: Text("Change Status"),
                    ),
                    DropdownMenuItem(
                      value: "Completed",
                      child: Text("Completed"),
                    ),
                    DropdownMenuItem(
                      value: "Cancelled",
                      child: Text("Cancelled"),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.print),
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Customer Information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customer",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text("Full Name: Shristi Singh"),
                    const Text("Email: shristi@gmail.com"),
                    const Text("Phone: +91 904 231 1212"),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text("View profile"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Order Info
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Info",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text("Shipping: Next express"),
                    const Text("Payment Method: Paypal"),
                    const Text("Status: Pending"),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Download info"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Deliver To
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Deliver to",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // You can add delivery information fields here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
