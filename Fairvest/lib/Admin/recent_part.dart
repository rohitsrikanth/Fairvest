import 'package:flutter/material.dart';
import 'customer_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecentPurchasesScreen(),
    );
  }
}

class RecentPurchasesScreen extends StatelessWidget {
  const RecentPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Add menu action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomerDetailsScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/logo.png', // Replace with your logo image
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'Fairvest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown and Date Range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: 'Change Status',
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                  },
                  items: <String>['Change Status', 'Delivered', 'Canceled']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Feb 16, 2022 - Feb 20, 2022',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Recent Purchases Title
            const Text(
              'Recent Purchases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.grey[200],
              child: const Row(
                children: [
                  Expanded(child: Text('Product', style: _tableHeaderStyle)),
                  Expanded(child: Text('Order ID', style: _tableHeaderStyle)),
                  Expanded(child: Text('Date', style: _tableHeaderStyle)),
                  Expanded(
                      child: Text('Customer Name', style: _tableHeaderStyle)),
                  Expanded(child: Text('Status', style: _tableHeaderStyle)),
                  Expanded(child: Text('Amount', style: _tableHeaderStyle)),
                ],
              ),
            ),
            // Table Rows
            Expanded(
              child: ListView.builder(
                itemCount: 8, // Number of rows
                itemBuilder: (context, index) {
                  return _buildTableRow(
                    context,
                    product: 'Lorem Ipsum',
                    orderId: '#2542${6 - index}',
                    date: 'Nov ${8 - index}, 2023',
                    customer: _getCustomerName(index),
                    status: index % 2 == 0 ? 'Delivered' : 'Canceled',
                    amount: '₹200.00',
                    avatarUrl: _getCustomerAvatar(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context, {
    required String product,
    required String orderId,
    required String date,
    required String customer,
    required String status,
    required String amount,
    required String avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (bool? value) {
                    // Handle checkbox
                  },
                ),
                Text(product, style: _tableRowStyle),
              ],
            ),
          ),
          Expanded(child: Text(orderId, style: _tableRowStyle)),
          Expanded(child: Text(date, style: _tableRowStyle)),
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 12,
                ),
                const SizedBox(width: 8),
                Text(customer, style: _tableRowStyle),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: status == 'Delivered' ? Colors.green : Colors.orange,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(status, style: _tableRowStyle),
              ],
            ),
          ),
          Expanded(child: Text(amount, style: _tableRowStyle)),
        ],
      ),
    );
  }

  String _getCustomerName(int index) {
    const names = [
      'Kavin',
      'Komael',
      'Nikhil',
      'Shivam',
      'Shadab',
      'Yogesh',
      'Sunita'
    ];
    return names[index % names.length];
  }

  String _getCustomerAvatar(int index) {
    const avatars = [
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
    ];
    return avatars[index % avatars.length];
  }
}

const TextStyle _tableHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

const TextStyle _tableRowStyle = TextStyle(
  fontSize: 14,
);
