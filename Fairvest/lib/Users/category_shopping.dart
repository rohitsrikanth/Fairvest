import 'dart:async';

import 'package:fairvest1/Sellers/Farmers/chat_bot.dart';
import 'package:fairvest1/Users/cart_page.dart';
import 'package:fairvest1/Users/profile_page.dart';
import 'package:fairvest1/search_page.dart';
import 'package:fairvest1/widget/custom_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fairvest1/constants.dart';
import 'package:fairvest1/product_detail_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruits & Vegetables',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FruitsAndVegetablesPage(category: 'S'),
    );
  }
}

class FruitsAndVegetablesPage extends StatefulWidget {
  final String category;
  FruitsAndVegetablesPage({required this.category});

  @override
  _FruitsAndVegetablesPageState createState() =>
      _FruitsAndVegetablesPageState();
}

class _FruitsAndVegetablesPageState extends State<FruitsAndVegetablesPage> {
  bool isLoading1 = true;
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentIndex = 0;
  Map<String, List<Map<String, dynamic>>> _productsByType = {
    'top_offers': [],
    'all_time_favorites': [],
    'trending_now': [],
  };
  late Map<String, dynamic> userData = {};
  late Future<List<dynamic>> _products;
  String farmer = "";
  late Map<String, dynamic> userDataq = {};

  @override
  void initState() {
    super.initState();
    // Initialize page controller for banner auto-play
    _fetchProducts('top_offers');
    _fetchProducts('all_time_favorites');
    _fetchProducts('trending_now');
    _products = fetchProducts();
  }

  @override
  void dispose() {
    // Dispose of resources to prevent memory leaks
    super.dispose();
  }

  Future<void> _fetchProducts(String productType) async {
    if (_productsByType[productType]!.isNotEmpty) return;

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products/$productType'));

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

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
        Uri.parse('$baseUrl/products200/${widget.category}')); // Flask API URL
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        title: Row(
          children: [
            Image.asset('assets/fairvest_logo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Fairvest',
                style: TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.shopping_cart),
        //     onPressed: () {},
        //   ),
        // ],
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(70),
        //   child: Column(
        //     children: [
        //       const Padding(
        //         padding: EdgeInsets.symmetric(horizontal: 16.0),
        //         child: Row(
        //           children: [
        //             Icon(Icons.local_shipping, color: Colors.white),
        //             SizedBox(width: 8),
        //             Text('Get it in 1 day*',
        //                 style: TextStyle(color: Colors.white)),
        //             Spacer(),
        //             Text('Kalyanpur, Kanpur',
        //                 style: TextStyle(color: Colors.white)),
        //           ],
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: Container(
        //           padding: const EdgeInsets.symmetric(horizontal: 12),
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(20),
        //           ),
        //           child: const TextField(
        //             decoration: InputDecoration(
        //               icon: Icon(Icons.search),
        //               hintText: 'Search products',
        //               border: InputBorder.none,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 20),
          // _buildFeaturedSection(
          //     "Top Offers", "Just in time for you!", 'top_offers'),
          // _buildFeaturedSection("All Time Favorites", "Your favorites await!",
          //     'all_time_favorites'),
          // _buildFeaturedSection("Trending Now",
          //     "What everyone is talking about!", 'trending_now'),
          FutureBuilder<List<dynamic>>(
            future: _products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products available'));
              }

              final products = snapshot.data!;
              return SizedBox(
                height: 750, // Set a fixed height for the ListView
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                      child: ProductCard(
                        imageUrl: product['image_path'] ?? '',
                        title: product['productname'] ?? 'No Title',
                        subtitle: product['description'] ?? 'No Description',
                        price: product['price']?.toString() ?? '0.00',
                        productId: product['product_id']?.toString() ?? '',
                        onAddToCart: addToCart,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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

  Widget _buildFeaturedProductItem(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
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
                    width: 130);
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> products) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
          child:
              Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (_, index) => _buildFeaturedProductItem(products[index]),
      ),
    );
  }

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
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final String productId;
  final Future<void> Function(String) onAddToCart;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.productId,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/placeholder1.jpeg',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                Text('Rs: $price',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
            onPressed: () async {
              // Add product to cart logic
              await onAddToCart(productId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added to cart!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
