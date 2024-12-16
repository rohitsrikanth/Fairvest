import 'package:flutter/material.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherScreen1(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen1 extends StatelessWidget {
  const WeatherScreen1({super.key});

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
                  onPressed: () {},
                ),
                const Text(
                  'Sep, 12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Today',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WeatherHourlyItem(time: "15.00", temp: "29°C"),
                WeatherHourlyItem(time: "16.00", temp: "26°C"),
                WeatherHourlyItem(time: "18.00", temp: "23°C"),
                WeatherHourlyItem(time: "19.00", temp: "22°C"),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Next Forecast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  WeatherDailyItem(date: 'Sep, 13', temp: '21°', icon: Icons.bolt),
                  WeatherDailyItem(date: 'Sep, 14', temp: '22°', icon: Icons.cloud),
                  WeatherDailyItem(date: 'Sep, 15', temp: '34°', icon: Icons.wb_sunny),
                  WeatherDailyItem(date: 'Sep, 16', temp: '27°', icon: Icons.cloud),
                  WeatherDailyItem(date: 'Sep, 17', temp: '32°', icon: Icons.wb_sunny),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherHourlyItem extends StatelessWidget {
  final String time;
  final String temp;

  const WeatherHourlyItem({required this.time, required this.temp, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.wb_sunny, color: Colors.white),
        const SizedBox(height: 5),
        Text(
          temp,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
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