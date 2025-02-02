import 'package:fairvest1/Users/login_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart' as geocoding; // Alias geocoding
import 'package:location/location.dart' as location; // Alias location

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign-up Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SignUpAddressPage(),
    );
  }
}

class SignUpAddressPage extends StatefulWidget {
  const SignUpAddressPage({super.key});

  @override
  _SignUpAddressPageState createState() => _SignUpAddressPageState();
}

class _SignUpAddressPageState extends State<SignUpAddressPage> {
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();

  String selectedAddressType = 'Home';
  bool showModal = false;

  Future<void> getAddressFromLatLng() async {
    location.Location locationService = location.Location();

    bool _serviceEnabled;
    location.PermissionStatus _permissionGranted;

    _serviceEnabled = await locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationService.requestService();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location service not enabled')),
        );
        return;
      }
    }

    _permissionGranted = await locationService.hasPermission();
    if (_permissionGranted == location.PermissionStatus.denied) {
      _permissionGranted = await locationService.requestPermission();
      if (_permissionGranted != location.PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    final location.LocationData locationData =
        await locationService.getLocation();

    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );
      geocoding.Placemark place = placemarks[0];
      setState(() {
        _houseController.text = place.street ?? '';
        _apartmentController.text = place.subLocality ?? '';
        _directionController.text = '${place.locality}, ${place.country}';
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching address: $e')),
      );
    }
  }

  Future<void> _saveAddressDetails() async {
  // Collect input values
  final addressDetails = {
    "address": {
      "house": _houseController.text.trim(),
      "apartment": _apartmentController.text.trim(),
      "city,state": _directionController.text.trim(),
    },
    "type": selectedAddressType,
  };

  // Validate inputs
  if (_houseController.text.trim().isEmpty ||
      _apartmentController.text.trim().isEmpty ||
      _directionController.text.trim().isEmpty ||
      selectedAddressType.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Please fill all the details')),
    );
    return; // Stop execution if validation fails
  }

  print(addressDetails);

  try {
    // API call
    final response = await http.post(
      Uri.parse('$baseUrl/buyers_sign3'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(addressDetails),
    );

    if (response.statusCode == 200) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign-in Successful!'),
            content: const Center(
              child: Icon(Icons.check_circle, color: Colors.green, size: 50),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Go'),
              ),
            ],
          );
        },
      );
    } else {
      // Show error message from the API response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  } catch (e) {
    // Handle exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Unable to save details.')),
    );
    print('Exception: $e'); // For debugging
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-up Page'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Address Fields
            _buildTextField(_houseController, 'House/Flat/Block-No'),
            const SizedBox(height: 10),
            _buildTextField(_apartmentController, 'Apartment/Road'),
            const SizedBox(height: 10),
            _buildTextField(_directionController, 'City, State'),
            const SizedBox(height: 20),

            // Fetch Address Button
            ElevatedButton.icon(
              onPressed: getAddressFromLatLng,
              icon: const Icon(Icons.location_pin),
              label: const Text('Use Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // Address Type
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAddressTypeButton('Home', Icons.home),
                const SizedBox(width: 20),
                _buildAddressTypeButton('Office', Icons.work),
                const SizedBox(width: 20),
                _buildAddressTypeButton('Other', Icons.location_pin),
              ],
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _saveAddressDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.green[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAddressTypeButton(String type, IconData icon) {
    bool isSelected = type == selectedAddressType;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddressType = type;
        });
      },
      child: Column(
        children: [
          Icon(icon, size: 30, color: isSelected ? Colors.green : Colors.grey),
          const SizedBox(height: 5),
          Text(type,
              style: TextStyle(color: isSelected ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }
}
