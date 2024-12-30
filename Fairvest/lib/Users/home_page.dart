import 'package:fairvest1/Sellers/Farmers/chat_bot.dart';
import 'package:fairvest1/Users/cart_page.dart';
import 'package:fairvest1/Users/profile_page.dart';
import 'package:fairvest1/product_detail_page.dart';
import 'package:fairvest1/search_page.dart';
import 'package:fairvest1/widget/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fairvest1/constants.dart';
import 'package:fairvest1/Users/category_shopping.dart';

class FairvestHomePage extends StatefulWidget {
  const FairvestHomePage({Key? key}) : super(key: key);

  @override
  _FairvestHomePageState createState() => _FairvestHomePageState();
}

class _FairvestHomePageState extends State<FairvestHomePage> {
  // Banner and Product Management
  int _currentIndex = 0;
  late PageController _pageController;

  // Dummy banner images (consider replacing with actual network images)
  final List<String> _bannerImages = [
    'assets/banner.png',
    'assets/banner.png',
    'assets/banner.png',
    'assets/banner.png',
    'assets/banner.png'
  ];
  late Map<String, dynamic> userData = {};
  bool isLoading1 = true;
  // State Management for Product Loading
  bool _isLoading = true;
  String _errorMessage = '';

  // Product Categories Storage
  Map<String, List<Map<String, dynamic>>> _productsByType = {
    'top_offers': [],
    'all_time_favorites': [],
    'trending_now': [],
  };

  @override
  void initState() {
    super.initState();
    // Initialize page controller for banner auto-play
    _pageController = PageController();
    _startAutoPlay();

    // Fetch products across different categories
    _fetchProducts('top_offers');
    _fetchProducts('all_time_favorites');
    _fetchProducts('trending_now');
  }

  @override
  void dispose() {
    // Dispose of resources to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  // Product Fetching Method with Robust Error Handling
  Future<void> _fetchProducts(String productType) async {
    if (_productsByType[productType]!.isNotEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productType'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['products'];

        setState(() {
          _productsByType[productType] = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load $productType products');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching $productType products: $e';
        _isLoading = false;
      });
      debugPrint(_errorMessage);
    }
  }

  Future<void> addToCart(String productId) async {
    final Uri url = Uri.parse('$baseUrl/add_to_cart');
    try {
      final response = await http.get(Uri.parse('$baseUrl/getuser'));
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading1 = false;
        });
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_name": userData['name'],
          "product_id": productId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData['message']);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product added to cart!")),
        );
      } else {
        print("Failed to add product to cart: ${response.body}");
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add product to cart.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  // Automated Banner Slider Logic
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
        _startAutoPlay(); // Recursive auto-play
      }
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

  // App Bar Construction
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

  // Main Body Construction
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerSlider(),
          const SizedBox(height: 20),
          _buildFeaturedSection(
              "Top Offers", "Just in time for you!", 'top_offers'),
          _buildFeaturedSection("All Time Favorites", "Your favorites await!",
              'all_time_favorites'),
          _buildFeaturedSection("Trending Now",
              "What everyone is talking about!", 'trending_now'),
          const SizedBox(height: 16),
          _buildShopByCategory(),
        ],
      ),
    );
  }

  // Bottom Navigation Bar Construction
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        //BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
      ],
      onTap: (index) {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const SearchPage()));
              break;
            case 3:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const CartPage()));
              break;
            case 4:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const DrawerMenuPage()));
              break;
            case 5:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => ChatBotPage()));
              break;
          }
        }
      },
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
    );
  }

  // Featured Product Section Builder
  Widget _buildFeaturedSection(
      String title, String subtitle, String productType) {
    final products = _productsByType[productType] ?? [];

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
          _buildProductList(products),
        ],
      ),
    );
  }

  // Intelligent Product List Builder
  Widget _buildProductList(List<Map<String, dynamic>> products) {
    // Handle different loading/error states
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Render product list
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (_, index) => _buildFeaturedProductItem(products[index]),
      ),
    );
  }

  // Banner Slider Implementation
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

  // Featured Product Item Renderer
  Widget _buildFeaturedProductItem(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Column(
          children: [
            Image.asset(
              product['image_path'] ??
                  'assets/Dataset/Fruits and Berries/pomegranate/Image_9.jpg',
              height: 70,
              width: 130,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: ${product['image_path']}');
                return Image.asset(
                  'assets/Dataset/Fruits and Berries/pomegranate/Image_9.jpg',
                  height: 70,
                  width: 130,
                );
              },
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      product['productname'] ?? 'Product Name',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${product['discountedprice'] ?? 0.0}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: ElevatedButton(
                onPressed: () => addToCart(product['productid']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shop By Category Section
  Widget _buildShopByCategory() {
    const categories = [
      {'title': 'Fresh Vegetables', 'image': 'assets/fresh_vegetables.jpg'},
      {'title': 'Fruits and Berries', 'image': 'assets/fruits.png'},
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
                        builder: (_) => FruitsAndVegetablesPage(
                            category: category['title'] ?? 'Default Category')),
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
}
