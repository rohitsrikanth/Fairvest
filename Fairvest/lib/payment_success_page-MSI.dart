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
    home: PaymentSuccessPage(
      amount: amount,
      isSingle : true,
    ),
  ));
}

class PaymentSuccessPage extends StatefulWidget {
  final double amount;
  bool isSingle ; // The cart items to display

   PaymentSuccessPage(
      {required this.amount, required this.isSingle, Key? key})
      : super(key: key);
  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> userData1 = {};

  bool isLoading = true;
// Replace with your base URL
  String currentTime = '';
  String referenceNumber = '';
  String dataToSend ="";
  String isSeller ='';
  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    fetchrefnum();
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
  }

  Future<void> fetchrefnum() async {
    try {
      dataToSend =""; 
      if (widget.isSingle) { 
        dataToSend = "0";
      } else { 
        dataToSend = "1"; 
      }
      final response =
          await http.get(Uri.parse('$baseUrl/orders/$dataToSend'));
      if (response.statusCode == 200) {
        setState(() {
          userData1 = jsonDecode(response.body);
          referenceNumber = userData1['reference_number'] ??
              'N/A'; // Get the reference number
          isSeller = userData1['isSeller'];
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

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isSeller == '1' ? FarmersHomePage() : FairvestHomePage(),
      ),
      (route) => false,
    );
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
                          detailRow('Ref Number', referenceNumber),
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
                  
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToHome();
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
