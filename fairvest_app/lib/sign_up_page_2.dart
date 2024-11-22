import 'package:flutter/material.dart';
import 'package:fairvest_app/sign_up_page_3.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestLocationPermission() async {
  var status = await Permission.location.status;

  if (status.isDenied) {
    // Request permission
    if (await Permission.location.request().isGranted) {
      print("Location permission granted.");
    } else {
      print("Location permission denied.");
    }
  } else if (status.isPermanentlyDenied) {
    // Navigate to app settings
    openAppSettings();
  }
}


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignUpPage2(),
  ));
}

class SignUpPage2 extends StatefulWidget {
  @override
  _SignUpPage2State createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  LatLng? currentLocation;
  String locationStatus = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    await checkAndRequestLocationPermission();
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationStatus =
        "Location services are disabled. Please enable them in settings.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationStatus =
          "Location permissions are denied. Please allow them in settings.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationStatus =
        "Location permissions are permanently denied. Please allow them in settings.";
      });
      return;
    }

    // Fetch location with timeout and fallback to last known position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        //timeLimit: Duration(seconds: 10), // Timeout added
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        locationStatus = "Location fetched successfully!";
      });
    } catch (e) {
      // Use last known position as fallback
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        setState(() {
          currentLocation =
              LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
          locationStatus = "Using last known location.";
        });
      } else {
        setState(() {
          locationStatus = "Failed to fetch location: ${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  'Sign-up Page',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Confirm Your Delivery Location',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Map with current location marker
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: currentLocation ??
                        LatLng(20.5937, 78.9629), // Default location (India)
                    zoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLocation!,
                            builder: (ctx) => Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (currentLocation == null)
                  Center(
                    child: Text(
                      locationStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Location Information and Next Button
          Container(
            color: Colors.green,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        currentLocation != null
                            ? "Latitude: ${currentLocation!.latitude}, Longitude: ${currentLocation!.longitude}"
                            : locationStatus,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentLocation != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage3()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please enable location services."),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
