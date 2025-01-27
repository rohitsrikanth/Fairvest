import 'package:fairvest1/Users/home_page.dart';
import 'package:fairvest1/centers/screens/login_page.dart';
import 'Users/sign_up_page_2.dart';
import 'package:flutter/material.dart';
import 'Users/login_page.dart';
import 'Sellers/login_page.dart';
import 'Sellers/Farmers/home_page.dart';
import 'Sellers/FoodMillOperators/home_page.dart';
import 'Sellers/wholesellers/home_page.dart';
import 'Sellers/P&C/home_page.dart';
import 'centers/theme/customer_management.dart';
import 'centers/screens/dashboard.dart';
import 'centers/screens/farmer_management.dart';
import 'centers/screens/inventory_management.dart';
import 'centers/screens/order_management.dart';
import 'centers/screens/payment_management.dart';
import 'centers/screens/product_management.dart';
import 'centers/screens/reports.dart';
import 'centers/screens/settings.dart';
import 'centers/screens/support.dart';
// import 'weather_detail_page.dart';
import 'weather_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fairvest',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        debugShowCheckedModeBanner:false,
        home: const FairvestScreen(),
        initialRoute: '/',
        routes: {
          '/farmer': (context) => const FarmersHomePage(),
          '/foodMillOperator': (context) => const FoodMillOperatorPage(),
          '/pesticidesSeller': (context) => const P_C_HomePage(),
          '/wholeSaleSellers': (context) => const WholeSellesHomePage(),
          '/bsign2': (context) => const SignUpPage2(),
          '/dashboard': (context) => const DashboardPage(),
          '/farmer-management': (context) => const FarmerManagementPage(),
          '/product-management': (context) => const ProductManagementPage(),
          '/order-management': (context) => const OrderManagementPage(),
          '/inventory-management': (context) => const InventoryManagementPage(),
          '/payment-management': (context) => const PaymentManagementPage(),
          //'/customer-management': (context) => const CustomerManagementPage(),
          '/reports': (context) => const ReportsPage(),
          '/support': (context) => const SupportPage(),
          '/settings': (context) => const SettingsPage(),
          '/weatherhome': (context) => const WeatherScreen(),
          '/userhome' :(context) => const FairvestHomePage()
        });
  }
}

class FairvestScreen extends StatelessWidget {
  const FairvestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8fc5b8),
      body: Column(
        children: [
          // Header Section
          Container(
            color: Colors.green,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/fairvest_logo.png', // Add your logo image in assets
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Fairvest– Growing Connections,\nHarvesting Fairness.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
Divider(thickness: 0, color: Colors.transparent),
          // Supply Chain Image Section
          // Supply Chain Image Section
Expanded(
  child: Container(
    width: double.infinity,
    child: Image.asset(
      'assets/supply_chain.png', // Add your supply chain image in assets
      fit: BoxFit.contain, // Ensures the image occupies the full width and scales properly
    ),
  ),
),


          // Centers Button Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Centers button action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LoginScreen()), // Replace with your Centers page
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'CENTERS',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Sell and Buy Button Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.store, size: 50, color: Colors.green),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Sell button action
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const sLoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'SELL',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.local_shipping,
                            size: 50, color: Colors.green),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'BUY',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                // const Text(
                //   'To know more about who we are?',
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.black,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
