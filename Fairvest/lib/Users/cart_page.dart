import 'package:fairvest1/Sellers/Farmers/chat_bot.dart';
import 'package:fairvest1/Users/home_page.dart';
import 'package:fairvest1/Users/my_orders_page.dart';
import 'package:fairvest1/Users/profile_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:fairvest1/widget/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  String userName = "";
  late Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
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
    String userName = userData['name'];
    final Uri url = Uri.parse('$baseUrl/get_cart?user_name=$userName');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          cartItems = responseData["cart"];
        });
      } else {
        print("Failed to load cart items: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load cart items.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.green),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get it in 1 day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userData['address'] != null)
                      Text(
                        'House No: ${userData['address']['house'] ?? 'N/A'}, '
                        'Apartment: ${userData['address']['apartment'] ?? 'N/A'},\n'
                        'Street: ${userData['address']['street'] ?? 'N/A'}, '
                        'Directions: ${userData['address']['directions'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      )
                    else
                      const Text(
                        'No Address Available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String productId, String name, String weight,
      String price, String originalPrice, String imagePath, int quantity) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Image.asset(
          imagePath ?? 'assets/placeholder1.jpeg',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/placeholder1.jpeg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("₹$price", style: const TextStyle(fontSize: 25)),
            Text("₹$originalPrice",
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough, fontSize: 12)),
            Text("Quantity: $quantity"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.remove, color: Colors.green),
                onPressed: () {
                  setState(() {
                    quantity = quantity > 1 ? quantity - 1 : quantity;
                  });
                }),
            Text("$quantity"),
            IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                }),
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
        title: const Text("Cart"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                _buildDeliveryAddress(),
                for (var item in cartItems)
                  _buildProductCard(
                    item['product_id'],
                    item['name'],
                    item['weight'],
                    item['price'],
                    item['original_price'],
                    item['image_path'],
                    item['quantity'],
                  ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummary(),
            const SizedBox(height: 10),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    double totalPrice = 0.0;
    double totalSavings = 0.0;

    for (var item in cartItems) {
      double price = double.parse(item['price'].toString());
      double originalPrice = double.parse(item['original_price'].toString());
      int quantity = item['quantity'];
      totalPrice += price * quantity;
      totalSavings += (originalPrice - price) * quantity;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "₹${totalPrice.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Saved ₹${totalSavings.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.green, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MyOrdersApp()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          icon: const Icon(Icons.flash_on),
          label: const Text("Get it now"),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
          ),
          icon: const Icon(Icons.schedule, color: Colors.black),
          label: const Text("Schedule delivery",
              style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    int _currentIndex = 1;

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
      ],
      currentIndex: _currentIndex,
      onTap: (index) {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const FairvestHomePage()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              break;
            case 2:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const CartPage()));
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
                  context, MaterialPageRoute(builder: (_) => OpenUrlPage()));
              break;
          }
        }
      },
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
    );
  }
}
