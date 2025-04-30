import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/widgets/custom_button.dart';

class AnalyticsReportsScreen extends StatefulWidget {
  const AnalyticsReportsScreen ({super.key});
  @override
  _AnalyticsReportsScreenState createState() => _AnalyticsReportsScreenState();
}

class _AnalyticsReportsScreenState extends State<AnalyticsReportsScreen> {
  String _selectedReport = 'User Activity Report';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: const Size.fromHeight(80), // Set AppBar height
          child: mainTopBar(title: 'Analytics & Reports'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // TopBar(
              //   title: 'Analytics & Reports',
              //   onBackPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Report Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Adds spacing between text and radio buttons
                    _buildReportTypeSelector(),
                    CustomButton(
                      text: 'Generate Report',
                      color: const Color(0xFF2A9D8F),
                      screenWidth: screenWidth,
                      onTap: () {},
                    ),
                    if (_selectedReport == 'Service Usage Report')
                      _buildServicePerformanceGraph(),
                    if (_selectedReport == 'Vendor Performance Report')
                      _buildVendorPerformanceGraph(),
                    if (_selectedReport == 'Feedback Analysis')
                      _buildFeedbackAnalysisGraph(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: const CustomBottomNavigationBar(
        //   currentIndex: 1,
        //  ),
        //  bottomNavigationBar:const  CustomBottomNavigationBar(),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RadioListTile<String>(
          title: const Text('Service Usage Report'),
          value: 'Service Usage Report',
          groupValue: _selectedReport,
          onChanged: (value) {
            setState(() {
              _selectedReport = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Vendor Performance Report'),
          value: 'Vendor Performance Report',
          groupValue: _selectedReport,
          onChanged: (value) {
            setState(() {
              _selectedReport = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Feedback Analysis'),
          value: 'Feedback Analysis',
          groupValue: _selectedReport,
          onChanged: (value) {
            setState(() {
              _selectedReport = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildServicePerformanceGraph() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  _buildBarChartGroupData(0, 8, Colors.orange),
                  _buildBarChartGroupData(1, 12, Colors.green),
                  _buildBarChartGroupData(2, 10, const Color(0xFF2A9D8F)),
                ],
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Service 1');
                          case 1:
                            return const Text('Service 2');
                          case 2:
                            return const Text('Service 3');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorPerformanceGraph() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vendor Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  _buildBarChartGroupData(0, 8, Colors.orange),
                  _buildBarChartGroupData(1, 12, Colors.green),
                  _buildBarChartGroupData(2, 10, const Color(0xFF2A9D8F)),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('Vendor ${value.toInt() + 1}');
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackAnalysisGraph() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                titlesData:const  FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      const FlSpot(1, 3),
                      const FlSpot(2, 1.5),
                      const FlSpot(3, 4),
                      const FlSpot(4, 3.5),
                    ],
                    isCurved: true,
                    color: Colors.orange,
                    dotData:const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarChartGroupData(int x, double y, Color barColor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 16,
        ),
      ],
    );
  }
}
