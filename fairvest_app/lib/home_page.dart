import 'package:fairvest_app/cart_page.dart';
import 'package:fairvest_app/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:fairvest_app/widget/custom_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fairvest',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FairvestHomePage(),
    );
  }
}

class FairvestHomePage extends StatefulWidget {
  @override
  _FairvestHomePageState createState() => _FairvestHomePageState();
}

class _FairvestHomePageState extends State<FairvestHomePage> {
  int _selectedIndex = 0;

  // Method to handle navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        toolbarHeight: 65, // Adjust height as needed
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/fairvest_logo.png', height: 40),
            SizedBox(width: 10),
            Text(
              'Fairvest',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true, // Center the entire content
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Section
              Text(
                'Shop by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildCategoryItem('Fresh Vegetables', 'assets/fresh_vegetables.jpg'),
                  _buildCategoryItem('Fruits & Berries', 'assets/fruits.png'),
                  _buildCategoryItem('Grains', 'assets/grains.jpg'),
                  _buildCategoryItem('Pulses', 'assets/pulses.jpg'),
                  _buildCategoryItem('Oil seeds', 'assets/oil_seeds.jpg'),
                  _buildCategoryItem('Oils', 'assets/oils.jpg'),
                ],
              ),
              SizedBox(height: 20),
              // Promotional Banner
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage('assets/banner.png'), // Replace with your banner image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Set the selected index
        selectedItemColor: Colors.teal, // Active tab color
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FairvestHomePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'You',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
        ],
      ),
    );
    drawer: CustomDrawer(); // Use the CustomDrawer widget

  }

  Widget _buildCategoryItem(String title, String imagePath) {
    return GestureDetector(
      onTap: () {}, // Add navigation or actions here
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
