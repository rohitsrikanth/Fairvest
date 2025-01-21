import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ProductAnalysisApp());
}

class ProductAnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List products = [];
  Map<String, dynamic> analysis = {};

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchAnalysis();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    }
  }

  Future<void> fetchAnalysis() async {
    final response = await http.get(Uri.parse('$baseUrl/analysis'));
    if (response.statusCode == 200) {
      setState(() {
        analysis = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Analysis")),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product['productname']),
                        subtitle: Text("Price: ₹${product['price']} | Star: ${product['star']}"),
                        trailing: Text("Discount: ${product['discount_percentage']}%"),
                      );
                    },
                  ),
                ),
                if (analysis.isNotEmpty)
                  Expanded(
                    child: Column(
                      children: [
                        Text("Top Discounted Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            itemCount: analysis['top_discounted'].length,
                            itemBuilder: (context, index) {
                              final product = analysis['top_discounted'][index];
                              return ListTile(
                                title: Text(product['productname']),
                                subtitle: Text("Discount: ${product['discount_percentage']}%"),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
