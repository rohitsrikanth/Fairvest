import 'package:fairvest1/Users/cart_page.dart';
import 'package:fairvest1/Users/my_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:fairvest1/Users/home_page.dart';

class DrawerMenuPage extends StatelessWidget {
  const DrawerMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Fairvest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FairvestHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Smart Basket / My List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOrdersPage()),
              );
            },
          ),
          const ExpansionTile(
            leading: Icon(Icons.category),
            title: Text('Shop By Category'),
            children: [
              /*ListTile(
                title: const Text('Fresh Vegetables'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FruitsAndVegetablesPage()),
                  );
                },
              ),
              ListTile(
                title: const Text('Fruits & Berries'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FruitsAndVegetablesPage()),
                  );
                },
              ),*/
            ],
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('FV Cookbook'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Gift Card'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analysis'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {},
          ),
          ExpansionTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            children: [
              ListTile(
                title: const Text('Question 1'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Question 2'),
                onTap: () {},
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact us'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
