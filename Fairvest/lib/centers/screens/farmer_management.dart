import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fairvest1/constants.dart';

class FarmerManagementPage extends StatefulWidget {
  const FarmerManagementPage({super.key});

  @override
  State<FarmerManagementPage> createState() => _FarmerManagementPageState();
}

class _FarmerManagementPageState extends State<FarmerManagementPage> {
  final List<Map<String, dynamic>> _farmers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFarmers();
  }

  Future<void> _fetchFarmers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/farmers'));
      if (response.statusCode == 200) {
        final List<dynamic> farmerList = jsonDecode(response.body);

        // Filter farmers whose ID starts with "SFAR"
        final filteredFarmers = farmerList.where((farmer) {
          return farmer['id'] != null &&
              farmer['id'].toString().startsWith("SFAR");
        }).toList();

        setState(() {
          _farmers.clear();
          _farmers
              .addAll(filteredFarmers.map((f) => Map<String, dynamic>.from(f)));
        });
      } else {
        _showError('Failed to fetch farmers.');
      }
    } catch (e) {
      _showError('An error occurred while fetching farmers: $e');
    }
  }

  Future<void> _addFarmerToBackend(Map<String, String> farmer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/farmers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(farmer),
      );
      if (response.statusCode == 201) {
        _fetchFarmers();
      } else {
        _showError('Failed to add farmer.');
      }
    } catch (e) {
      _showError('An error occurred while adding farmer: $e');
    }
  }

  Future<void> _updateFarmerInBackend(
      String farmerId, Map<String, String> farmer) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/farmers/$farmerId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(farmer),
      );
      if (response.statusCode == 200) {
        _fetchFarmers();
      } else {
        _showError('Failed to update farmer.');
      }
    } catch (e) {
      _showError('An error occurred while updating farmer: $e');
    }
  }

  void _addFarmer(BuildContext context) {
    _showFarmerForm(
      context: context,
      onSubmit: (newFarmer) async {
        await _addFarmerToBackend(newFarmer);
      },
    );
  }

  void _showFarmerForm({
    required BuildContext context,
    Map<String, String>? farmer,
    required Function(Map<String, String>) onSubmit,
  }) {
    final _nameController = TextEditingController(text: farmer?['name']);
    final _emailController = TextEditingController(text: farmer?['email']);
    final _phoneController = TextEditingController(text: farmer?['phone']);
    final _locationController =
        TextEditingController(text: farmer?['location']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(farmer == null ? 'Add Farmer' : 'Edit Farmer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'Email (Optional)'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Farm Location'),
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
                final updatedFarmer = {
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'phone': _phoneController.text,
                  'location': _locationController.text,
                };
                onSubmit(updatedFarmer);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(farmer == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFarmers = _farmers.where((farmer) {
      return farmer['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Farmers',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFarmers.length,
              itemBuilder: (context, index) {
                final farmer = filteredFarmers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(farmer['name'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${farmer['id'] ?? 'N/A'}'),
                        Text('Email: ${farmer['email'] ?? 'N/A'}'),
                        Text('Phone: ${farmer['phone'] ?? 'N/A'}'),
                        Text('Location: ${farmer['location'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showFarmerForm(
                          context: context,
                          farmer: {
                            'id': farmer['id'],
                            'name': farmer['name'],
                            'email': farmer['email'],
                            'phone': farmer['phone'],
                            'location': farmer['location'],
                          },
                          onSubmit: (updatedFarmer) async {
                            await _updateFarmerInBackend(
                                farmer['id'], updatedFarmer);
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addFarmer(context);
            },
            child: const Text('Add Farmer'),
          ),
        ],
      ),
    );
  }
}
