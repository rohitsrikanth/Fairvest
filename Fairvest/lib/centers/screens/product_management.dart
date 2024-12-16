import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:fairvest1/constants.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final List<Map<String, dynamic>> _products = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products from the API
  Future<void> _fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products?search=$_searchQuery'));

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        setState(() {
          _products.clear(); // Clear previous data to avoid duplicates
          _products.addAll(products.map((e) => Map<String, dynamic>.from(e)));
        });
      } else {
        _showSnackBar('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error fetching products: $e');
    }
  }

  // Add or update a product
  Future<void> _addOrUpdateProduct({
    required Map<String, dynamic> product,
    required bool isUpdate,
  }) async {
    final url =
        isUpdate ? '$baseUrl/products/${product['id']}' : '$baseUrl/products';
    final request =
        http.MultipartRequest(isUpdate ? 'PUT' : 'POST', Uri.parse(url));

    // Add product fields to the request
    request.fields['name'] = product['name'] ?? '';
    request.fields['productId'] = product['productId'] ?? '';
    request.fields['farmerId'] = product['farmerId'] ?? '';
    if (product['image'] != null) {
      try {
        request.files
            .add(await http.MultipartFile.fromPath('image', product['image']));
      } catch (e) {
        _showSnackBar('Invalid image file: $e');
        return;
      }
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(isUpdate
            ? 'Product updated successfully'
            : 'Product added successfully');
        _fetchProducts();
      } else {
        _showSnackBar(
            'Failed to ${isUpdate ? 'update' : 'add'} product: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  // Delete a product
  Future<void> _deleteProduct(int productId) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/products/$productId'));

      if (response.statusCode == 200) {
        _showSnackBar('Product deleted successfully');
        _fetchProducts();
      } else {
        _showSnackBar('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error deleting product: $e');
    }
  }

  // Show a snack bar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Show the product form in a dialog
  void _showProductForm({
    required BuildContext context,
    Map<String, dynamic>? product,
    required Function(Map<String, dynamic>) onSubmit,
  }) {
    final nameController = TextEditingController(text: product?['name']);
    final productIdController =
        TextEditingController(text: product?['productId']);
    final farmerIdController =
        TextEditingController(text: product?['farmerId']);
    File? imageFile;

    void pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: productIdController,
                  decoration: const InputDecoration(labelText: 'Product ID'),
                ),
                TextField(
                  controller: farmerIdController,
                  decoration: const InputDecoration(labelText: 'Farmer ID'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    imageFile != null
                        ? Image.file(imageFile!,
                            width: 80, height: 80, fit: BoxFit.cover)
                        : const Text('No image selected'),
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text('Upload Image'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newProduct = {
                  'id': product?['id'],
                  'name': nameController.text,
                  'productId': productIdController.text,
                  'farmerId': farmerIdController.text,
                  'image': imageFile?.path,
                };
                onSubmit(newProduct);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(product == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      return product['name']
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _fetchProducts(); // Fetch filtered products
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  leading: product['image'] != null &&
                          File(product['image']).existsSync()
                      ? Image.file(File(product['image']),
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                  title: Text(product['name'] ?? 'Unknown'),
                  subtitle: Text(
                    'Product ID: ${product['productId'] ?? 'N/A'}\nFarmer ID: ${product['farmerId'] ?? 'N/A'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showProductForm(
                            context: context,
                            product: product,
                            onSubmit: (updatedProduct) {
                              _addOrUpdateProduct(
                                product: updatedProduct,
                                isUpdate: true,
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteProduct(product['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showProductForm(
                context: context,
                onSubmit: (newProduct) {
                  _addOrUpdateProduct(
                    product: newProduct,
                    isUpdate: false,
                  );
                },
              );
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
