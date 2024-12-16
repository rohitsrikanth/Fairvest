import 'package:flutter/material.dart';

class InventoryManagementPage extends StatelessWidget {
  const InventoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Product: Wheat'),
            subtitle: const Text('Stock: 200 kg'),
            trailing: ElevatedButton(
              onPressed: () {
                // Restock logic
              },
              child: const Text('Restock'),
            ),
          ),
          ListTile(
            title: const Text('Product: Rice'),
            subtitle: const Text('Stock: 150 kg'),
            trailing: ElevatedButton(
              onPressed: () {
                // Restock logic
              },
              child: const Text('Restock'),
            ),
          ),
        ],
      ),
    );
  }
}
