import 'package:fairvest_app/cart_page.dart';
import 'package:fairvest_app/category_shopping.dart';
import 'package:fairvest_app/my_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:fairvest_app/home_page.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
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
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FairvestHomePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_basket),
            title: Text('Smart Basket / My List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('My Orders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrdersPage()),
              );
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.category),
            title: Text('Shop By Category'),
            children: [
              ListTile(
                title: Text('Fresh Vegetables'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FruitsAndVegetablesPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Fruits & Berries'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FruitsAndVegetablesPage()),
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('FV Cookbook'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text('Gift Card'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Analysis'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {},
          ),
          ExpansionTile(
            leading: Icon(Icons.help_outline),
            title: Text('FAQ'),
            children: [
              ListTile(
                title: Text('Question 1'),
                onTap: () {},
              ),
              ListTile(
                title: Text('Question 2'),
                onTap: () {},
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contact us'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
