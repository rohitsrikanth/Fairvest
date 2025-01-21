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
  bool _isAddingToCart = false;
  late Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> productFeedbacks = [];
  bool _isLoadingFeedbacks = true;
  Map<String, dynamic> farmerData = {};
  bool _isLoadingFarmer = true;
  double _farmerAverageRating = 0.0;
  bool _isExpanded = false;



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
    }
  }

  Future<void> _fetchProductFeedbacks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product_feedbacks/${widget.product['productid']}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> feedbacks = json.decode(response.body);
        setState(() {
          productFeedbacks = feedbacks.cast<Map<String, dynamic>>();
          _isLoadingFeedbacks = false;
        });
      } else {
        throw Exception('Failed to fetch feedbacks');
      }
    } catch (e) {
      print('Error fetching feedbacks: $e');
      setState(() {
        _isLoadingFeedbacks = false;
      });
    }
  }

  Future<void> _addToCart(String productId) async {
  setState(() {
    _isAddingToCart = true;
  });

  await _fetchUserData();

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
      // Try with a fallback URL
      final Uri fallbackUrl = Uri.parse('$baseUrl/add_to_cart1');
      try {
        final response = await http.post(
          fallbackUrl,
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
      }
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

    

  Future<void> _buyNow() async {
    final productId = widget.product['productid'];

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/process_order'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "product_id": productId,
          "user_id": userData['id'],
        }),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              amount: widget.product['price'],
              isSingle: true,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process the order')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while processing the order')),
      );
    }
  }

  Future<void> _fetchFarmerDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/farmer/${widget.product['farmerid']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          farmerData = data;
          // Calculate average rating
          if (data['feedback'] != null && data['feedback'].isNotEmpty) {
            double totalRating = 0;
            for (var feedback in data['feedback']) {
              totalRating += feedback['rating'] as num;
            }
            _farmerAverageRating = totalRating / data['feedback'].length;
          }
          _isLoadingFarmer = false;
        });
      } else {
        throw Exception('Failed to fetch farmer details');
      }
    } catch (e) {
      print('Error fetching farmer details: $e');
      setState(() {
        _isLoadingFarmer = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProductFeedbacks();
    _fetchFarmerDetails();
    _buildFeedbackSection();

  }

  Widget _buildImageCarousel() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: PageView(
          children: [
            Image.asset(
              widget.product['image_path'],
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product['productname'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${widget.product['price']}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'In Stock: ${widget.product['quantity']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product['description'],
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Feedbacks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${productFeedbacks.length} reviews',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingFeedbacks)
              const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            else if (productFeedbacks.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No feedbacks yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productFeedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = productFeedbacks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          feedback['user_name']?[0].toUpperCase() ?? 'U',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                feedback['user_name'] ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: List.generate(
                                  feedback['rating'] ?? 5,
                                  (index) => const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedback['feedback_text'] ?? '',
                            style: const TextStyle(height: 1.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedback['date'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isAddingToCart ? null : () => _addToCart(widget.product['productid']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isAddingToCart
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _buyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerDetailsSection() {
  if (_isLoadingFarmer) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.green),
    );
  }

  bool _isExpanded = false; // Initialize toggle for "More Info"

  Widget _buildInfoRow(IconData icon, String info) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            info,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  return StatefulBuilder(
    builder: (context, setState) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: Text(
                      farmerData['name']?[0].toUpperCase() ?? 'F',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmerData['name'] ?? 'Unknown Farmer',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 20, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              _farmerAverageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${farmerData['feedback']?.length ?? 0} reviews)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 32),
                _buildInfoRow(Icons.email, farmerData['email'] ?? 'N/A'),
                _buildInfoRow(Icons.phone, farmerData['phone'] ?? 'N/A'),
                _buildInfoRow(
                  Icons.business,
                  farmerData['business_type'] ?? 'Farmer',
                ),
                // const Divider(height: 32),
                // const Text(
                //   'Recent Sales',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // if (farmerData['sales_history'] != null)
                //   ListView.builder(
                //     shrinkWrap: true,
                //     physics: const NeverScrollableScrollPhysics(),
                //     itemCount: (farmerData['sales_history'] as List).length.clamp(0, 3),
                //     itemBuilder: (context, index) {
                //       final sale = farmerData['sales_history'][index];
                //       return ListTile(
                //         contentPadding: EdgeInsets.zero,
                //         title: Text(sale['product']),
                //         subtitle: Text('Quantity: ${sale['quantity']} units'),
                //         trailing: Text(
                //           '₹${sale['revenue']}',
                //           style: const TextStyle(
                //             color: Colors.green,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // const Divider(height: 32),
                // const Text(
                //   'Farmer Reviews',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 8),
                // if (farmerData['feedback'] != null)
                //   ListView.builder(
                //     shrinkWrap: true,
                //     physics: const NeverScrollableScrollPhysics(),
                //     itemCount: (farmerData['feedback'] as List).length,
                //     itemBuilder: (context, index) {
                //       final feedback = farmerData['feedback'][index];
                //       return Card(
                //         margin: const EdgeInsets.symmetric(vertical: 4),
                //         child: Padding(
                //           padding: const EdgeInsets.all(12),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Row(
                //                 children: [
                //                   ...List.generate(
                //                     feedback['rating'],
                //                     (index) => const Icon(
                //                       Icons.star,
                //                       size: 16,
                //                       color: Colors.amber,
                //                     ),
                //                   ),
                //                   const SizedBox(width: 8),
                //                   Text(
                //                     'Buyer ${feedback['buyer_id']}',
                //                     style: TextStyle(
                //                       color: Colors.grey[600],
                //                       fontSize: 12,
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //               const SizedBox(height: 4),
                //               Text(
                //                 feedback['comment'],
                //                 style: const TextStyle(height: 1.5),
                //               ),
                //             ],
                //           ),
                //         ),
                //       );
                //     },
                //   ),
              ],
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['productname']),
        backgroundColor: Colors.green,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageCarousel(),
                  const SizedBox(height: 20),
                  _buildProductInfo(),
                  const SizedBox(height: 20),
                  _buildFarmerDetailsSection(),
                  const SizedBox(height: 20),
                  _buildFeedbackSection(), // Added farmer details section
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: _buildActionButtons(),
      ),
    );
  }

}