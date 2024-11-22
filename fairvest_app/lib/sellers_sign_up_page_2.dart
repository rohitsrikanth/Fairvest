import 'package:flutter/material.dart';

void main() {
  runApp(const FieldLocationApp());
}

class FieldLocationApp extends StatelessWidget {
  const FieldLocationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SellersSignUpPage2(),
    );
  }
}

class SellersSignUpPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Sign-up Page',
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Text
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.green,
            child: const Text(
              'Set your field location',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          // Google Map-like Area
          Expanded(
            child: Container(
              color: Colors.grey[300], // Placeholder for map background
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/map.png', // Replace with your map image or Map widget
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Field Location Selector
          Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Select Field Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Kattarbakkam, Kancheepuram, Tamil Nadu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Change action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
