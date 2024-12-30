import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_detail_page.dart'; // Import the product detail page

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  late Map<String, dynamic> userData = {};
  bool isLoading = true;
  String userName = "";
  // Function to perform search request to Flask backend
  Future<void> _searchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getuser'));
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/getuser1'));
        if (response.statusCode == 200) {
          setState(() {
            userData = jsonDecode(response.body);
            isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch user details');
        }
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }

    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _errorMessage = '';
    });

    try {
      final String endpoint = userData['_id'] != null ? 'search1' : 'search';
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['products'];
        setState(() {
          _searchResults = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load search results';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for products...',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchProducts();
                }
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            return ListTile(
                              title: Text(product['productname'] ?? 'No Name'),
                              subtitle: Text('${product['price']}'),
                              leading: Image.asset(
                                  product['image_path'] ??
                                      'assets/placeholder1.jpeg',
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                return Image.asset('assets/placeholder1.jpeg');
                              }),
                              onTap: () {
                                // Navigate to product detail page and pass the product data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailPage(
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
