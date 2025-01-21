import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyOrdersApp());
}

class MyOrdersApp extends StatelessWidget {
  const MyOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyOrdersPage(),
    );
  }
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders data from the backend API
  Future<void> _fetchOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/get_orders'));

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
      print(orders);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("My Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {Navigator.pushNamed(context, '/userhome');
},
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green[100],
              border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Image.asset(
                    'assets/fairvest_logo.png', // Replace with your asset path
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Faivest",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Past Orders Section
         Expanded(
  child: orders.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order, context);
          },
        ),
),


          // Footer Section
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[200],
            child: const Column(
              children: [
                Text(
                  "Write to us at customerservice@Fairvest.com",
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
                  "for help with other previous orders.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailPage(order: order),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: Image.asset(
          order['logoPath'] ?? 'assets/default_logo.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivered ${order['date'] ?? 'Unknown Date'}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              "Arrived between ${order['time'] ?? 'Unknown Time'}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Image.asset(
                order['products'][0]['image_path'] ?? 'assets/placeholder1.jpeg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}




class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Map<String, double> productRatings = {};
  Map<String, TextEditingController> reviewControllers = {};
  Map<String, bool> isReviewSubmitting = {};
  Map<String, bool> hasReviewed = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and ratings for each product
    for (var product in widget.order['products']) {
      final productId = product['productid'];
      reviewControllers[productId] = TextEditingController();
      productRatings[productId] = 0;
      isReviewSubmitting[productId] = false;
      _checkExistingReview(productId);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    reviewControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _checkExistingReview(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check_review/${widget.order['order']}/$productId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hasReviewed[productId] = data['exists'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking existing review: $e');
    }
  }

  Future<void> _submitReview(Map<String, dynamic> product) async {
    final productId = product['productid'];
    
    if (isReviewSubmitting[productId] ?? false) return;

    final rating = productRatings[productId] ?? 0;
    final review = reviewControllers[productId]?.text.trim() ?? '';

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (review.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    setState(() {
      isReviewSubmitting[productId] = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit_review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': widget.order['order'],
          'product_id': productId,
          'rating': rating,
          'review': review,
          'farmer_id': product['farmer_id'],
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          hasReviewed[productId] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting review')),
      );
    } finally {
      setState(() {
        isReviewSubmitting[productId] = false;
      });
    }
  }

  Widget _buildRatingStars(String productId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < (productRatings[productId] ?? 0) 
                ? Icons.star 
                : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              productRatings[productId] = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildReviewSection(Map<String, dynamic> product) {
    final productId = product['productid'];
    final hasReviewedProduct = hasReviewed[productId] ?? false;

    if (hasReviewedProduct) {
      return const Card(
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Review submitted', style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate this product:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Center(child: _buildRatingStars(productId)),
            const SizedBox(height: 8),
            TextField(
              controller: reviewControllers[productId],
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: isReviewSubmitting[productId] == true
                    ? null
                    : () => _submitReview(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: isReviewSubmitting[productId] == true
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Order #${widget.order['order']}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        widget.order['logoPath'],
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Order #${widget.order['order']}",
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date: ${widget.order['date']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Time: ${widget.order['time']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Ordered Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order['products'].length,
              itemBuilder: (context, index) {
                final product = widget.order['products'][index];
                return Column(
                  children: [
                    Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Image.asset(
                          product['image_path'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          product['productname'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(product['description']),
                        trailing: Text(
                          "₹${product['discountedprice']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    _buildReviewSection(product),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
