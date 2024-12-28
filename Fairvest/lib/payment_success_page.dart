import 'package:fairvest1/Sellers/Farmers/home_page.dart';
import 'package:fairvest1/Users/home_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the time
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http;

void main() {
  double amount = 50.0; // Example amount
  runApp(MaterialApp(
    home: PaymentSuccessPage(amount: amount),
  ));
}

class PaymentSuccessPage extends StatefulWidget {
  final double amount;
  const PaymentSuccessPage({required this.amount, Key? key}) : super(key: key);
  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
// Replace with your base URL
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    getCurrentTime();
  }

  Future<void> fetchUserDetails() async {
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
      print('Error fetching user details: $e');
    }
  }

  void getCurrentTime() {
    setState(() {
      currentTime = DateFormat('dd-MM-yyyy, HH:mm:ss').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 10),
                  Text(
                    'Payment Success!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Divider(color: Colors.grey),
                          detailRow('Ref Number', '000085752257'),
                          detailRow('Payment Time', currentTime),
                          detailRow('Payment Method', 'Bank Transfer'),
                          detailRow('Sender Name', userData['name'] ?? 'N/A'),
                          detailRow('Amount',
                              'IDR  ₹${widget.amount.toStringAsFixed(2)}'),
                          detailRow('Admin Fee', 'IDR 5.00'),
                          detailRow(
                            'Payment Status',
                            'Success',
                            valueStyle: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logic to download PDF receipt
                    },
                    icon: Icon(Icons.download),
                    label: Text('Get PDF Receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FairvestHomePage()),
                      );
                    },
                    child: Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget detailRow(String title, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          Text(value, style: valueStyle ?? TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
