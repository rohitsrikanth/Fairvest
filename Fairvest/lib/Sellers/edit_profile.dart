import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SellerEditPage extends StatefulWidget {

  @override
  _SellerEditPageState createState() => _SellerEditPageState();
}

class _SellerEditPageState extends State<SellerEditPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _businessTypeController = TextEditingController();

  // List of business types
  final List<String> _businessTypes = [
    "Farmer",
    "Food Mill Operator",
    "Pesticide and Crop Seller",
    "Wholesale Seller"
  ];

  // Selected business type
  String? _selectedBusinessType;

  // Function to fetch existing seller info from the backend
  Future<void> _fetchSellerInfo() async {
    final response = await http.get(Uri.parse('$baseUrl/seller'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _nameController.text = data['name'];
        _emailController.text = data['email'];
        _phoneController.text = data['phone'];
        _passwordController.text = data['password'];
        _selectedBusinessType = data['business_type'];
      });
    } else {
      // Handle error
      print('Failed to load seller info');
    }
  }

  // Function to update the seller info
  Future<void> _updateSellerInfo() async {
    final response = await http.put(
      Uri.parse('$baseUrl/seller'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "password": _passwordController.text,
        "business_type": _selectedBusinessType,
      }),
    );

    if (response.statusCode == 200) {
      // Success - handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seller Info Updated')));
    } else {
      // Error - handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSellerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Seller Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              // TextFormField(
              //   controller: _passwordController,
              //   decoration: InputDecoration(labelText: 'Password'),
              //   obscureText: true,
              //   validator: (value) => value!.isEmpty ? 'Please enter password' : null,
              // ),
              DropdownButtonFormField<String>(
                value: _selectedBusinessType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBusinessType = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Business Type'),
                items: _businessTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a business type' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateSellerInfo();
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
