import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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

  Future<void> fetchForecast() async {
    try {
      final url = Uri.parse(
          '$baseUrl/weather/forecast/latlon/${widget.lat}/${widget.lon}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if 'forecast' key exists in the data
        if (data.containsKey('forecast')) {
          setState(() {
            forecastData = data['forecast'];
          });
        } else {
          setState(() {
            error = 'Unexpected data format: No forecast data found';
          });
        }
      } else {
        setState(() => error = 'Failed to load forecast');
      }
    } catch (e) {
      setState(() => error = e.toString());
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
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
                  child:
                      Text(error, style: const TextStyle(color: Colors.white)))
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
                      temp: '${forecast['temp'].round()}°',
                      icon: getWeatherIcon(forecast['main']),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Keep your existing WeatherDailyItem widget
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
