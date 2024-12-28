import 'package:fairvest1/sellers/login_page.dart';
import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart' as location;

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

  @override
  void initState() {
    super.initState();
    // Automatically fetch address when the page is loaded
    getAddressFromLatLng();
  }

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
    final addressDetails = {
      "location": _directionController.text,
      "type": selectedAddressType,
    };

    print(addressDetails);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sellers_sign3'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(addressDetails),
      );

      if (response.statusCode == 200) {
        setState(() {
          showModal = true;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign-in Successful!'),
              content: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: const Center(
                  child:
                      Icon(Icons.check_circle, color: Colors.green, size: 50),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const sLoginPage(),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Address Type'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(_directionController, 'City, State'),
              const SizedBox(height: 20),
              // Wrap the row inside an Expanded to avoid overflow
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAddressTypeButton('Farming Land', Icons.landscape),
                    const SizedBox(width: 20),
                    _buildAddressTypeButton('Factory', Icons.factory),
                    const SizedBox(width: 20),
                    _buildAddressTypeButton(
                        'Pesticide and Crop Selling Shop', Icons.local_florist),
                    const SizedBox(width: 20),
                    _buildAddressTypeButton('Wholesale Sellers', Icons.store),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Selected: $selectedAddressType',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 40),
              // Save button at the bottom of the screen
              ElevatedButton(
                onPressed: _saveAddressDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
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
