import 'package:flutter/material.dart';

class CustomerManagementPage extends StatelessWidget {
  const CustomerManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Customer: Alice Johnson'),
            subtitle: Text('Last Order: Order #101'),
          ),
          ListTile(
            title: Text('Customer: Bob Brown'),
            subtitle: Text('Last Order: Order #102'),
          ),
        ],
      ),
    );
  }
}
