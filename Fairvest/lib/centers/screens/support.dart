import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support and Help'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('How to Add a Farmer?'),
            subtitle: Text('Follow these steps...'),
          ),
          ListTile(
            title: Text('How to Manage Orders?'),
            subtitle: Text('Follow these steps...'),
          ),
        ],
      ),
    );
  }
}
