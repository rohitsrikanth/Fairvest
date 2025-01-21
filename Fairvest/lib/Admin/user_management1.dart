import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fairvest1/constants.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class UsersPage extends StatefulWidget {
  final String user;
  UsersPage({Key? key, required this.user}) : super(key: key);
  @override
  _UsersPageState createState() => _UsersPageState(user: user);
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  final String user;

  _UsersPageState({required this.user});

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/get_users_list/$user'));
    if (response.statusCode == 200) {
      setState(() {
        users = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        isLoading = false;
      });
    } else {
      print('Failed to load users');
    }
  }


double calculateRevenueIncreasePercentage(List<Map<String, dynamic>> salesHistory) {  // Sort sales history by date
  salesHistory.sort((a, b) => DateFormat('yyyy-MM-dd').parse(a['date']).compareTo(DateFormat('yyyy-MM-dd').parse(b['date'])));

  double initialRevenue = salesHistory.first['revenue'].toDouble();
  double finalRevenue = salesHistory.last['revenue'].toDouble();

  double percentageIncrease = ((finalRevenue - initialRevenue) / initialRevenue) * 100;
  return percentageIncrease;
}

// Example usage with your provided data


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                print(user["sales_history"]);

                return ListTile(
  leading: CircleAvatar(
    backgroundImage: user['profileImage'] != null
        ? NetworkImage(user['profileImage'])
        : AssetImage('assets/default_profile.png'), // Default image for null
  ),
  title: Text(user['name'] ?? 'Unknown User'), // Fallback for null name
  subtitle: Builder(
    builder: (_) {
      if (user['sales_history'] != null && user['sales_history'].isNotEmpty) {
        final salesHistory = List<Map<String, dynamic>>.from(user['sales_history']);
        if (salesHistory.isNotEmpty) {
          final revenueIncrease = calculateRevenueIncreasePercentage(salesHistory).toStringAsFixed(2);
          return Text(
            'ID: ${user['id'] ?? 'N/A'}\n'
            'Revenue Increase: $revenueIncrease%',
          );
        }
      }
      // Fallback for purchase history or no sales history
      return Text(
        'ID: ${user['id'] ?? 'N/A'}\n'
        'Purchase History: ${user['purchaseHistory'] != null && user['purchaseHistory'].isNotEmpty
            ? user['purchaseHistory']?.join(', ')
            : 'No purchases'}',
      );
    },
  ),
  isThreeLine: true,
  onTap: user['id'] != null // Handle tap only if user data exists
      ? () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(user: user),
            ),
          )
      : null,
);

              },
            ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailPage({required this.user});

 @override
Widget build(BuildContext context) {
  // Safely handle salesHistory by ensuring it is a list of maps
  final List<Map<String, dynamic>> salesHistory = (user['sales_history'] is List)
      ? List<Map<String, dynamic>>.from(user['sales_history'])
      : [];

  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
      title: Text(user['name'] ?? 'User Details'),
    ),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: salesHistory.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user['profileImage'] != null
                        ? NetworkImage(user['profileImage']!)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Name: ${user['name'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('ID: ${user['id'] ?? 'N/A'}'),
                SizedBox(height: 16),
                Text(
                  'Sales History Analysis:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: (salesHistory.length * 50.0).clamp(screenWidth, double.infinity),
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: salesHistory
                                  .map((data) {
                                    final date = data['date'];
                                    final revenue = data['revenue'];
                                    // Ensure date and revenue are non-null and valid
                                    if (date != null && revenue != null) {
                                      try {
                                        return FlSpot(
                                          DateFormat('yyyy-MM-dd')
                                              .parse(date)
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          revenue.toDouble(),
                                        );
                                      } catch (e) {
                                        // Skip invalid entries
                                        return null;
                                      }
                                    }
                                    return null; // Skip invalid data
                                  })
                                  .whereType<FlSpot>() // Remove null spots
                                  .toList(),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.green,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.withOpacity(0.3),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = DateTime.fromMillisecondsSinceEpoch(
                                      value.toInt());
                                  return Text(DateFormat('MMM dd').format(date));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          minX: salesHistory
                              .map((data) =>
                                  DateFormat('yyyy-MM-dd')
                                      .parse(data['date'])
                                      .millisecondsSinceEpoch
                                      .toDouble())
                              .reduce((a, b) => a < b ? a : b),
                          maxX: salesHistory
                              .map((data) =>
                                  DateFormat('yyyy-MM-dd')
                                      .parse(data['date'])
                                      .millisecondsSinceEpoch
                                      .toDouble())
                              .reduce((a, b) => a > b ? a : b),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'No sales history available for this user.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
    ),
  );
}

}

void main() => runApp(MaterialApp(
      home: UsersPage(user: 'Consumer'),
    ));
