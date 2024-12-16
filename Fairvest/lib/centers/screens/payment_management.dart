import 'package:flutter/material.dart';

class PaymentManagementPage extends StatelessWidget {
  const PaymentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Payment to Farmer: John Doe'),
            subtitle: const Text('Amount: ₹10,000 | Status: Pending'),
            trailing: ElevatedButton(
              onPressed: () {
                // Mark as paid logic
              },
              child: const Text('Mark Paid'),
            ),
          ),
          const ListTile(
            title: Text('Payment to Farmer: Jane Smith'),
            subtitle: Text('Amount: ₹12,000 | Status: Paid'),
          ),
        ],
      ),
    );
  }
}
