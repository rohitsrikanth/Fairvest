import 'package:flutter/material.dart';

void main() => runApp(UploadProductApp());

class UploadProductApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadProductPage(),
    );
  }
}

class UploadProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Upload Your Product",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.upload),
          onPressed: () {
            // Add functionality here if needed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionCard(
              context,
              icon: Icons.book,
              label: "Select type of your Product",
              trailing: const Icon(Icons.arrow_drop_down, size: 30),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              icon: Icons.description,
              label: "Give description below\n200 words",
              trailing: null,
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              icon: Icons.image,
              label: "Upload Image",
              trailing: const Icon(Icons.add, size: 30),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              icon: Icons.scale,
              label: "Select no of units (in Kg)",
              trailing: const Icon(Icons.arrow_drop_down, size: 30),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              icon: Icons.calendar_today,
              label: "Select Date",
              trailing: const Icon(Icons.calendar_month, size: 30, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon, required String label, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
