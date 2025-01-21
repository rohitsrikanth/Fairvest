import 'dart:convert';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  final String userId; // Pass the userId for fetching user data

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController cityStateController = TextEditingController();

  String userType = "Home"; // Default user type
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
  try {
    // Send the GET request to fetch user data
    final response = await http.get(Uri.parse('$baseUrl/getuser'));
    
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body); // Decode the JSON response
      setState(() {
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? '';
        phoneController.text = user['phone'] ?? '';
        passwordController.text = user['password'] ?? '';
        houseController.text = user['address']['house'] ?? '';
        apartmentController.text = user['address']['apartment'] ?? '';
        cityStateController.text = user['address']['city,state'] ?? '';
        userType = user['type'] ?? 'Home';
        isLoading = false;
      });
    } else {
      // Handle the case where the user is not found or some other error occurs
      print('Failed to fetch user data: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${jsonDecode(response.body)['error']}')),
      );
    }
  } catch (e) {
    print('Error fetching user data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching user data')),
    );
  }
}


  Future<void> _updateUserData() async {
  final updatedData = {
    "name": nameController.text,
    "email": emailController.text,
    "phone": phoneController.text,
    "password": passwordController.text,
    "address": {
      "house": houseController.text,
      "apartment": apartmentController.text,
      "city,state": cityStateController.text,
    },
    "type": userType,
  };

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/update_user'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      // Show success dialog and navigate to home
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${response.body}')),
      );
    }
  } catch (e) {
    print('Error updating user data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating user data')),
    );
  }
}

void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Success"),
        content: const Text("Profile updated successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pushReplacementNamed('/userhome'); // Navigate to home page
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    // TextField(
                    //   controller: passwordController,
                    //   decoration: const InputDecoration(labelText: 'Password'),
                    //   obscureText: true,
                    // ),
                    const SizedBox(height: 16),
                    const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: houseController,
                      decoration: const InputDecoration(labelText: 'House'),
                    ),
                    TextField(
                      controller: apartmentController,
                      decoration: const InputDecoration(labelText: 'Apartment'),
                    ),
                    TextField(
                      controller: cityStateController,
                      decoration: const InputDecoration(labelText: 'City, State'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: userType,
                      onChanged: (value) {
                        setState(() {
                          userType = value!;
                        });
                      },
                      items: ['Home', 'Office', 'Other']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
