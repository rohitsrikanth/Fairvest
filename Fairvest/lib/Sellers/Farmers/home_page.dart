import 'dart:convert';
import 'package:fairvest1/Sellers/Farmers/profile_page.dart';
import 'package:fairvest1/Users/cart_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FarmersHomePage extends StatefulWidget {
  const FarmersHomePage({super.key});

  @override
  State<FarmersHomePage> createState() => _FarmersHomePageState();
}

class _FarmersHomePageState extends State<FarmersHomePage> {
  late Future<List<dynamic>> _products;
  String farmer = "";
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  Future<List<dynamic>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('$baseUrl/products')); // Flask API URL
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Map<String, dynamic>> addToCart(String productId) async {
    print(productId);
    try {
      final response = await http.get(Uri.parse('$baseUrl/getuser1'));
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }

    const String apiUrl = '$baseUrl/add_to_cart1'; // Replace with your API URL
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body:
          jsonEncode({'farmer_id': userData["name"], 'product_id': productId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'Failed to connect to server'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Image.asset('assets/fairvest_logo.png', height: 40),
            const SizedBox(width: 8),
            const Text(
              'Fairvest',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FarmersProfilePage()),
              );
            },
            icon: const Icon(Icons.account_circle, size: 35),
          ),
          IconButton(
            onPressed: () {
              // Add functionality for cart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart, size: 35),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
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
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              print(product);
              return ProductCard(
                imageUrl: product['image_path'] ?? '',
                title: product['productname'] ?? 'No Title',
                subtitle: product['description'] ?? 'No Description',
                price: product['price']?.toString() ?? '0.00',
                productId: product['product_id']?.toString() ?? '',
                onAddToCart: addToCart,
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final String productId;
  final Future<Map<String, dynamic>> Function(String) onAddToCart;

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
            child: Image.network(
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
              final response = await onAddToCart(productId);
              if (response['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added to cart!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to add product: ${response['message']}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
