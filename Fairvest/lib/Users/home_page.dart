import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category_shopping.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fairvest',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const FairvestHomePage(),
    );
  }
}

class FairvestHomePage extends StatefulWidget {
  const FairvestHomePage({super.key});

  @override
  _FairvestHomePageState createState() => _FairvestHomePageState();
}

class _FairvestHomePageState extends State<FairvestHomePage> {
  int _selectedIndex = 0;
  int _currentIndex = 0;
  late PageController _pageController;

  // Dummy banner images
  final List<String> _bannerImages = [
    'assets/banner.png',
    'assets/banner.png',
    'assets/banner.png',
    'assets/banner.png',
    'assets/banner.png'
  ];

  // Dynamic product data fetched from backend
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
    _fetchProducts('top_offers'); // Default product type
    _fetchProducts('all_time_favorites');
    _fetchProducts('trending_now');
  }

  // Fetch products from backend
  Future<void> _fetchProducts(String productType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productType'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _products = data.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  // Auto-play method for the banner slider
  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          (_currentIndex + 1) % _bannerImages.length,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
        setState(
            () => _currentIndex = (_currentIndex + 1) % _bannerImages.length);
        _startAutoPlay(); // Recursive call
      }
    });
  }

  // Navigation bar tap handler
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.green,
      toolbarHeight: 65,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/fairvest_logo.png', height: 40),
          const SizedBox(width: 10),
          const Text(
            'Fairvest',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerSlider(),
          const SizedBox(height: 20),
          _buildFeaturedSection("Top Offers", "Just in"),
          _buildFeaturedSection("All Time Favourites", "Fresh Picks"),
          _buildFeaturedSection("Trending Now", "Best for Freshness"),
          const SizedBox(height: 16),
          _buildShopByCategory(),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return SizedBox(
      height: 180.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _bannerImages.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(_bannerImages[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _products.length,
              itemBuilder: (_, index) =>
                  _buildFeaturedProductItem(_products[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductItem(Map<String, dynamic> product) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            product['image_url'],
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 5),
          Text(
            product['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${product['price']}',
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildShopByCategory() {
    const categories = [
      {'title': 'Fresh Vegetables', 'image': 'assets/fresh_vegetables.jpg'},
      {'title': 'Fruits & Berries', 'image': 'assets/fruits.png'},
      {'title': 'Grains', 'image': 'assets/grains.jpg'},
      {'title': 'Pulses', 'image': 'assets/pulses.jpg'},
      {'title': 'Oil seeds', 'image': 'assets/oil_seeds.jpg'},
      {'title': 'Oils', 'image': 'assets/oils.jpg'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop by Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(
                category['title']!,
                category['image']!,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FruitsAndVegetablesPage()),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                  image: AssetImage(imagePath), fit: BoxFit.cover),
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
        BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
      ],
    );
  }
}
