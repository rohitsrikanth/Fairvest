import 'package:fairvest1/constants.dart';
import 'package:fairvest1/payment_page_1.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;
  bool _isAddingToCart = false;
  late Map<String, dynamic> userData = {}; // Ensure this is initialized
  List<String> reviews = []; // List to hold reviews

  // Function to fetch user data
  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getuser'));
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching user data.')),
      );
    }
  }

  // Function to submit review to the backend
  Future<void> _submitReview() async {
    final review = _reviewController.text.trim();
    if (review.isEmpty) return;

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit_review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productid': widget.product['productid'],
          'review': review,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          reviews.add(review); // Add review to the list
          _isSubmittingReview = false;
        });
        _reviewController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } else {
        setState(() {
          _isSubmittingReview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmittingReview = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting review')),
      );
    }
  }

  // Function to add product to the cart
  Future<void> _addToCart(String productId) async {
    setState(() {
      _isAddingToCart = true;
    });

    // Fetch user data before adding product to cart
    await _fetchUserData(); // Corrected function call

    final Uri url = Uri.parse('$baseUrl/add_to_cart');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added to cart!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add product to cart.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  // Function to proceed to checkout (Buy Now)
  void _buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(amount: widget.product['price']),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Corrected function call here
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['productname']),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image Carousel
              SizedBox(
                height: 200,
                child: PageView(
                  children: [
                    Image.asset(
                      product['image_path'],
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product['productname'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Price: \$${product['price']}'),
              const SizedBox(height: 8),
              Text('Quantity: ${product['quantity']}'),
              const SizedBox(height: 8),
              Text('Description: ${product['description']}'),
              const SizedBox(height: 16),
              const Text(
                'Add a Review:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  hintText: 'Enter your review here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _isSubmittingReview
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Submit Review'),
                    ),
              const SizedBox(height: 20),
              // Display submitted reviews
              const Text(
                'Reviews:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...reviews.map((review) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('- $review'),
                  )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _isAddingToCart
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _addToCart(product['productid']),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text('Add to Cart'),
                        ),
                  ElevatedButton(
                    onPressed: _buyNow,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Buy Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const CheckoutPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text('Proceeding to checkout for ${product['productname']}'),
      ),
    );
  }
}
