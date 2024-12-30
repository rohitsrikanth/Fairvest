import 'package:flutter/material.dart';
import 'package:fairvest1/payment_success_page.dart';

void main() {
  double amount = 50.0; // Example amount
  List<Map<String, dynamic>> cartItems = []; // Example cart items
  runApp(MaterialApp(
    home: PaymentPage(amount: amount, cartItems: cartItems),
  ));
}

class PaymentPage extends StatefulWidget {
  final double amount; // The total savings or payment amount
  final List<Map<String, dynamic>> cartItems; // The cart items to display

  PaymentPage({required this.amount, required this.cartItems});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    // GST calculation (example)
    final gst = widget.amount * 0.18;
    final payableAmount = widget.amount + gst;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Payment Information"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recharge and Payable Information
              Text("Recharge Amount", style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text("₹${widget.amount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text("GST (18%)", style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text("₹${gst.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text("Payable Amount",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text("₹${payableAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 20),

              // Cashback Section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("100% extra on recharge of ₹50",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                "₹50 Cashback in AstroBharat Wallet with this Recharge",
                                style: TextStyle(fontSize: 14))),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Payment Options Header
              Text("Pay directly with your favourite UPI apps",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              SizedBox(height: 16),

              // UPI Apps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PaymentOptionIcon(
                      assetPath: 'assets/gpay.png', label: 'GPay'),
                  PaymentOptionIcon(
                      assetPath: 'assets/phonepe.png', label: 'PhonePe'),
                  PaymentOptionIcon(
                      assetPath: 'assets/bhim.png', label: 'BHIM'),
                  PaymentOptionIcon(
                      assetPath: 'assets/paytm.png', label: 'Paytm'),
                ],
              ),
              SizedBox(height: 20),

              // Pay with Other UPI Apps
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSuccessPage(
                        amount:
                            widget.amount, // Correctly passing the amount here
                        cartItems: widget
                            .cartItems, // Correctly passing the cart items here
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Pay with other UPI apps",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Other Payment Methods
              Text("Other Payments Methods",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              SizedBox(height: 12),
              Row(
                children: [
                  PaymentOptionIcon(
                      assetPath: 'assets/netbanking.png', label: 'Net Banking'),
                  PaymentOptionIcon(
                      assetPath: 'assets/credpay.png', label: 'CRED Pay'),
                ],
              ),
              SizedBox(height: 20),

              // Swipe to Pay
              Container(
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Swipe to Pay",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(width: 8),
                    Icon(Icons.double_arrow, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentOptionIcon extends StatelessWidget {
  final String assetPath;
  final String label;

  PaymentOptionIcon({required this.assetPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(assetPath),
          radius: 28,
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
