import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Center Name: Fairvest Center 1'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            title: Text('Commission Rate: 5%'),
            trailing: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
