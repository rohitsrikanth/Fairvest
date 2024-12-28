import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fairvest1/constants.dart';

class ForecastScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const ForecastScreen({required this.lat, required this.lon, Key? key})
      : super(key: key);

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<dynamic>? forecastData;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.cloud;
    }
  }

  Future<void> fetchForecast() async {
    try {
      final url = Uri.parse(
          '$baseUrl/weather/forecast/latlon/${widget.lat}/${widget.lon}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate the response structure
        if (data is Map<String, dynamic> &&
            data.containsKey('list') &&
            data['list'] is List) {
          final List<dynamic> allForecasts = data['list'];
          final Map<String, dynamic> dailyForecasts = {};

          // Group forecasts by date and select the one closest to 12:00
          for (var forecast in allForecasts) {
            final DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
            final String dateKey = DateFormat('yyyy-MM-dd').format(dateTime);

            // Choose the forecast closest to noon (12:00)
            if (!dailyForecasts.containsKey(dateKey) ||
                (dateTime.hour - 12).abs() <
                    (DateTime.fromMillisecondsSinceEpoch(
                                    dailyForecasts[dateKey]['dt'] * 1000)
                                .hour -
                            12)
                        .abs()) {
              dailyForecasts[dateKey] = forecast;
            }
          }

          // Extract up to 5 days of data
          setState(() {
            forecastData = dailyForecasts.values.take(5).toList();
            error = ''; // Clear any existing error
          });
        } else {
          setState(() {
            error = 'Unexpected data format: No forecast data found';
            print('Data format error. Received: $data');
          });
        }
      } else {
        setState(() {
          error =
              'Failed to load forecast. Status code: ${response.statusCode}';
          print('HTTP Error: ${response.statusCode}');
          print('Response body: ${response.body}');
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        error = 'Error: $e';
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      });
    }
  }

  String kelvinToCelsius(double kelvin) {
    return (kelvin - 273.15).round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    DateFormat('MMM, dd').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '5-Day Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (error.isNotEmpty)
                Center(
                    child: Text(error,
                        style: const TextStyle(color: Colors.white)))
              else if (forecastData == null)
                const Center(
                    child: CircularProgressIndicator(color: Colors.white))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: forecastData!.length,
                    itemBuilder: (context, index) {
                      final forecast = forecastData![index];
                      return WeatherDailyItem(
                        date: DateFormat('MMM, dd').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              forecast['dt'] * 1000),
                        ),
                        temp: '${kelvinToCelsius(forecast['main']['temp'])}°C',
                        icon: getWeatherIcon(forecast['weather'][0]['main']),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherDailyItem extends StatelessWidget {
  final String date;
  final String temp;
  final IconData icon;

  const WeatherDailyItem({
    required this.date,
    required this.temp,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                temp,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
