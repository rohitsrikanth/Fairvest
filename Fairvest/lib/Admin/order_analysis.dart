import 'package:fairvest1/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderAnalyticsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order Analytics Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TrendsPage(),
    TopProductsPage(),
    BuyerStatsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Analytics Dashboard'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Trends'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Top Products'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Buyers'),
        ],
      ),
    );
  }
}




class TrendsPage extends StatefulWidget {
  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  List<FlSpot> _orderTrends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderTrends();
  }

  Future<void> _fetchOrderTrends() async {
    final response = await http.get(Uri.parse('$baseUrl/orders/trends'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _orderTrends = data.map<FlSpot>((item) {
          return FlSpot(item['date'].toDouble(), item['count'].toDouble());
        }).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load trends');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _orderTrends,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                  ),
                ],
              ),
            ),
          );
  }
}


class TopProductsPage extends StatefulWidget {
  @override
  _TopProductsPageState createState() => _TopProductsPageState();
}

class _TopProductsPageState extends State<TopProductsPage> {
  List<BarChartGroupData> _topProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopProducts();
  }

  Future<void> _fetchTopProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/top-products100'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _topProducts = data.map<BarChartGroupData>((item) {
          return BarChartGroupData(
            x: item['product_id'].hashCode,
            barRods: [
BarChartRodData(
  fromY: 0,
  toY: item['total_quantity'].toDouble(), // Correct parameter usage.
  color: Colors.green,
)
            ],
          );
        }).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load top products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                barGroups: _topProducts,
                borderData: FlBorderData(show: false),
              ),
            ),
          );
  }
}


class BuyerStatsPage extends StatefulWidget {
  @override
  _BuyerStatsPageState createState() => _BuyerStatsPageState();
}

class _BuyerStatsPageState extends State<BuyerStatsPage> {
  List<dynamic> _buyerStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBuyerStats();
  }

  Future<void> _fetchBuyerStats() async {
    final response = await http.get(Uri.parse('$baseUrl/buyer-stats'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _buyerStats = data;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load buyer stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _buyerStats.length,
            itemBuilder: (context, index) {
              final buyer = _buyerStats[index];
              return ListTile(
                title: Text(buyer['_id']),
                subtitle: Text('Total Orders: ${buyer['total_orders']}'),
              );
            },
          );
  }
}
