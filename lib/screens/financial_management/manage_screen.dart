import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gomed_admin/screens/financial_management/payment_screen.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';
import 'package:gomed_admin/widgets/topbar.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: const Size.fromHeight(80), // Set AppBar height
          child: mainTopBar(title: 'Manage Finances'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // TopBar(
              //   title: 'Manage Users',
              //   onBackPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Financial Overview',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Total Earnings',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    AspectRatio(
                      aspectRatio: 1.7,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      getTimeLabel(value),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '\$${value.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: 6,
                            minY: 0,
                            maxY: 100,
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 10),
                                  FlSpot(1, 20),
                                  FlSpot(2, 30),
                                  FlSpot(3, 40),
                                  FlSpot(4, 60),
                                  FlSpot(5, 80),
                                  FlSpot(6, 100),
                                ],
                                isCurved: true,
                                barWidth: 2,
                                color: const Color(0xFF2A9D8F),
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Pending Payments',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    _buildPendingPaymentsList(),
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    _buildSearchBar(),
                    _buildTransactionHistory(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar:const  CustomBottomNavigationBar(),
      ),
    );
  }

  String getTimeLabel(double value) {
    switch (value.toInt()) {
      case 0:
        return 'Jan';
      case 1:
        return 'Feb';
      case 2:
        return 'Mar';
      case 3:
        return 'Apr';
      case 4:
        return 'May';
      case 5:
        return 'Jun';
      case 6:
        return 'Jul';
      default:
        return '';
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (query) {
          setState(() {
            searchQuery = query;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search Transactions by date or vendor',
          suffixIcon: const Icon(
            Icons.search,
            size: 25,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingPaymentsList() {
    final pendingPayments = [
      {'username': 'user1', 'amount': 120.50},
      {'username': 'user2', 'amount': 85.75},
      {'username': 'user3', 'amount': 30.00},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingPayments.length,
      itemBuilder: (context, index) {
        final payment = pendingPayments[index];
        final username = payment['username'] as String? ??
            'Unknown User'; // Cast and provide default
        final amount =
            payment['amount'] as double? ?? 0.0; // Cast and provide default

        return Card(
          color: Color(0xFFD2F1E4),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$username has to pay \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16.0),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          username: username,
                          amount: amount,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2A9D8F), // Set button color
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionHistory() {
    final transactions = [
      {'username': 'user4', 'amount': 200.00, 'date': '2024-08-01'},
      {'username': 'user5', 'amount': 150.00, 'date': '2024-08-02'},
      {'username': 'user6', 'amount': 75.00, 'date': '2024-08-03'},
      {'username': 'user7', 'amount': 300.00, 'date': '2024-08-04'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          color: Color(0xFFD2F1E4),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${transaction['username']} Has Paid \$${transaction['amount']}',
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                'Date: ${transaction['date']}',
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your onPressed logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2A9D8F), // Set button color
                  ),
                  child: const Text(
                    'Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
