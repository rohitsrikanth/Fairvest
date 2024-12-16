import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController();
  String weatherData = "";

  Future<void> fetchWeatherByCity(String cityName) async {
    final url = Uri.parse('http://127.0.0.1:5000/weather/$cityName');
    print(cityName);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(response.body)['weather'];
      });
    } else {
      setState(() {
        weatherData = "Failed to load weather data";
      });
    }
  }

  Future<void> fetchWeatherByLatLon(String lat, String lon) async {
    final url = Uri.parse('http://127.0.0.1:5000/weather/latlon/$lat/$lon');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(response.body)['weather'];
      });
    } else {
      setState(() {
        weatherData = "Failed to load weather data";
      });
    }
  }

  Future<void> fetchWeatherForecast(String lat, String lon) async {
    final url =
        Uri.parse('http://127.0.0.1:5000/weather/forecast/latlon/$lat/$lon');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(response.body)['forecast'];
      });
    } else {
      setState(() {
        weatherData = "Failed to load forecast data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'Enter city name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                fetchWeatherByCity(cityController.text);
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 16),
            Text(weatherData),
          ],
        ),
      ),
    );
  }
}
