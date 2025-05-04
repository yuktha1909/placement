import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Sample data - In a real app, this would come from an API or database
  final Map<String, dynamic> dashboardData = {
    'totalStudents': 1245,
    'totalCompanies': 78,
    'ongoingDrives': 12,
    'placedStudents': 876,
    'placementPercentage': 70.4,
    'departmentPlacements': [
      {'department': 'Computer Science', 'placed': 92},
      {'department': 'Electronics', 'placed': 78},
      {'department': 'Mechanical', 'placed': 65},
      {'department': 'Civil', 'placed': 58},
      {'department': 'Electrical', 'placed': 72},
    ],
    'topCompanies': [
      {'name': 'Google', 'hired': 24},
      {'name': 'Microsoft', 'hired': 18},
      {'name': 'Amazon', 'hired': 15},
      {'name': 'IBM', 'hired': 12},
      {'name': 'Infosys', 'hired': 34},
    ],
    'packages': {
      'highest': 4500000,
      'average': 850000,
      'lowest': 350000,
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Dashboard'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              
              // Summary Statistics Cards
              GridView.count(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    'Total Students',
                    dashboardData['totalStudents'].toString(),
                    Colors.blue,
                    'assets/icons/total_students.png',
                  ),
                  _buildStatCard(
                    'Total Companies',
                    dashboardData['totalCompanies'].toString(),
                    Colors.orange,
                    'assets/icons/companies.png',
                  ),
                  _buildStatCard(
                    'Ongoing Drives',
                    dashboardData['ongoingDrives'].toString(),
                    Colors.purple,
                    'assets/icons/pending_interviews.png',
                  ),
                  _buildStatCard(
                    'Placed Students',
                    '${dashboardData['placedStudents']} (${dashboardData['placementPercentage']}%)',
                    Colors.green,
                    'assets/icons/placed_students.png',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Department Placements Chart
              _buildSectionHeader('Department-wise Placements'),
              const SizedBox(height: 8),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _buildDepartmentChart(),
              ),
              
              const SizedBox(height: 24),
              
              // Top Companies
              _buildSectionHeader('Top Recruiting Companies'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ...dashboardData['topCompanies'].map<Widget>((company) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                company['name'],
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: LinearProgressIndicator(
                                value: company['hired'] / dashboardData['totalStudents'],
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${company['hired']} students',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Package Statistics
              _buildSectionHeader('Package Statistics (in LPA)'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPackageInfo('Highest', dashboardData['packages']['highest'] / 100000),
                    _buildPackageInfo('Average', dashboardData['packages']['average'] / 100000),
                    _buildPackageInfo('Lowest', dashboardData['packages']['lowest'] / 100000),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 4;
    } else if (width > 800) {
      return 2;
    } else {
      return 1;
    }
  }

  Widget _buildStatCard(String title, String value, Color color, String assetPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Image.asset(
                assetPath,
                width: 24,
                height: 24,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // View more action
          },
          child: const Text('View More'),
        ),
      ],
    );
  }

  Widget _buildDepartmentChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        minY: 0,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${dashboardData['departmentPlacements'][groupIndex]['department']}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${rod.toY.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                String shortName = dashboardData['departmentPlacements'][value.toInt()]['department']
                    .toString()
                    .split(' ')
                    .map((e) => e[0])
                    .join('');
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    shortName,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          show: true,
          checkToShowHorizontalLine: (value) => value % 20 == 0,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        barGroups: List.generate(
          dashboardData['departmentPlacements'].length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dashboardData['departmentPlacements'][i]['placed'].toDouble(),
                color: _getBarColor(dashboardData['departmentPlacements'][i]['placed'].toDouble()),
                width: 18,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBarColor(double value) {
    if (value >= 80) {
      return Colors.green;
    } else if (value >= 60) {
      return Colors.blue;
    } else if (value >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildPackageInfo(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} LPA',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}