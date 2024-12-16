import 'dart:io';
import 'package:flutter/material.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '101',
      'farmerId': 'F001',
      'farmerName': 'John Doe',
      'status': 'Pending',
      'productId': 'P101',
      'productName': 'Wheat',
      'image': null,
      'driverId': 'D101',
      'driverName': 'Alex Johnson',
    },
    {
      'id': '102',
      'farmerId': 'F002',
      'farmerName': 'Jane Smith',
      'status': 'Dispatched',
      'productId': 'P102',
      'productName': 'Corn',
      'image': null,
      'driverId': 'D102',
      'driverName': 'Michael Brown',
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _getFilteredOrders(String status) {
    return _orders.where((order) {
      return order['status'] == status &&
          (order['id']!.contains(_searchQuery) ||
              order['farmerName']!
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Order #${order['id']}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text('Product ID: ${order['productId']}'),
                Text('Product Name: ${order['productName']}'),
                const SizedBox(height: 10),
                Text('Farmer ID: ${order['farmerId']}'),
                Text('Farmer Name: ${order['farmerName']}'),
                const SizedBox(height: 10),
                Text('Driver ID: ${order['driverId']}'),
                Text('Driver Name: ${order['driverName']}'),
                const SizedBox(height: 10),
                Text('Product Image:',
                    style: Theme.of(context).textTheme.bodyLarge),
                order['image'] != null
                    ? Image.file(File(order['image']),
                        width: 100, height: 100, fit: BoxFit.cover)
                    : const Text('No image uploaded'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showLiveTracking(context, order);
                  },
                  child: const Text('Live Track Order'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLiveTracking(BuildContext context, Map<String, dynamic> order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveTrackingPage(orderId: order['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Dispatched'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Orders',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Pending Orders
                  _buildOrderList('Pending'),
                  // Dispatched Orders
                  _buildOrderList('Dispatched'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    final orders = _getFilteredOrders(status);

    if (orders.isEmpty) {
      return const Center(
        child: Text('No orders found'),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text('Order #${order['id']}'),
          subtitle: Text(
              'Farmer: ${order['farmerName']} | Status: ${order['status']}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showOrderDetails(context, order);
          },
        );
      },
    );
  }
}

class LiveTrackingPage extends StatelessWidget {
  final String orderId;

  const LiveTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
      ),
      body: Center(
        child:
            Text('Live tracking for Order #$orderId is not implemented yet.'),
      ),
    );
  }
}
