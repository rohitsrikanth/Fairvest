import 'package:fairvest1/constants.dart';
import 'package:fairvest1/weather_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? weatherData;
  String errorMessage = "";
  Position? currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndWeather();
  }

  Future<void> _getCurrentLocationAndWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      currentLocation = await Geolocator.getCurrentPosition();
      await fetchWeatherByLatLon(
        currentLocation!.latitude.toString(),
        currentLocation!.longitude.toString(),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchWeatherByLatLon(String lat, String lon) async {
    try {
      final url = Uri.parse('$baseUrl/weather/latlon/$lat/$lon');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          // Access the nested weather data
          weatherData = jsonDecode(data['weather']);
          errorMessage = "";
        });
      } else {
        setState(() {
          errorMessage = "Failed to load weather data";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  String getWeatherIcon(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  String formatTime(dynamic timestamp) {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(weatherData?['name'] ?? 'Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocationAndWeather,
          ),
        ],
      ),
      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : weatherData == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              if (weatherData!['weather'] != null)
                                Image.network(
                                  getWeatherIcon(
                                      weatherData!['weather'][0]['icon']),
                                  height: 100,
                                ),
                              Text(
                                '${(weatherData!['main']['temp'] - 273.15).round()}°C',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              Text(
                                weatherData!['weather'][0]['description']
                                    .toString()
                                    .toUpperCase(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailsCard([
                        _buildDetailItem(
                          'Feels Like',
                          '${(weatherData!['main']['feels_like'] - 273.15).round()}°C',
                          Icons.thermostat,
                        ),
                        _buildDetailItem(
                          'Humidity',
                          '${weatherData!['main']['humidity']}%',
                          Icons.water_drop,
                        ),
                        _buildDetailItem(
                          'Wind Speed',
                          '${weatherData!['wind']['speed']} m/s',
                          Icons.air,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailsCard([
                        _buildDetailItem(
                          'Pressure',
                          '${weatherData!['main']['pressure']} hPa',
                          Icons.speed,
                        ),
                        _buildDetailItem(
                          'Visibility',
                          '${weatherData!['visibility'] / 1000} km',
                          Icons.visibility,
                        ),
                        _buildDetailItem(
                          'Clouds',
                          '${weatherData!['clouds']['all']}%',
                          Icons.cloud,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildSunCard(),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Replace with your actual latitude and longitude values
                            double lat = weatherData!['coord']['lat'];
                            double lon = weatherData!['coord']['lon'];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ForecastScreen(lat: lat, lon: lon),
                              ),
                            );
                          },
                          child: const Text('5 Day Forecast'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailsCard(List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSunCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDetailItem(
              'Sunrise',
              formatTime(weatherData!['sys']['sunrise']),
              Icons.wb_sunny,
            ),
            _buildDetailItem(
              'Sunset',
              formatTime(weatherData!['sys']['sunset']),
              Icons.nights_stay,
            ),
          ],
        ),
      ),
    );
  }
}
