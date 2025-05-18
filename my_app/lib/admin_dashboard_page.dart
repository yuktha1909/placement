import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_placement_page.dart';
import 'view_placements_page.dart';
import 'update_placement_page.dart';
import 'placement_events_page.dart';
import 'add_student_page.dart';
import 'view_student_page.dart';
import 'update_status_screen.dart';
import 'select_student_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final String token;
  const AdminDashboardPage({Key? key, required this.token}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Map<String, dynamic>> _placements = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> dashboardData = {
    'totalStudents': 0,
    'totalCompanies': 0,
    'ongoingDrives': 0,
    'placedStudents': 0,
    'placementPercentage': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
    _loadPlacements();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.175.14:5000/admin/dashboard'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          dashboardData = jsonDecode(response.body);
        });
      } else {
        setState(() {
          _error = 'Failed to load dashboard stats';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Dashboard error: $e';
      });
    }
  }

  Future<void> _loadPlacements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp = await http.get(
        Uri.parse('http://192.168.175.14:5000/placements'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['placements'] as List;
        setState(() {
          _placements = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load placements: ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading placements: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePlacement(int id) async {
    try {
      final resp = await http.delete(
        Uri.parse('http://192.168.175.14:5000/placements/$id'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        setState(() {
          _placements.removeWhere((p) => p['id'] == id);
        });
      } else {
        setState(() {
          _error = 'Delete failed: ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error deleting placement: $e';
      });
    }
  }

  Widget _buildMenu(BuildContext ctx) {
    return ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text(
            'Admin Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Placement'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => AddPlacementPage(token: widget.token),
              ),
            ).then((_) => _loadPlacements());
          },
        ),
        ListTile(
          leading: Icon(Icons.list),
          title: Text('View Placements'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => ViewPlacementsPage(token: widget.token),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.event),
          title: Text('Placement Events'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => PlacementEventsPage(token: widget.token),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text('Add Student'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => AddStudentPage(token: widget.token),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.group),
          title: Text('View Students'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => ViewStudentsPage(token: widget.token),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.update),
          title: Text('Update Status'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => SelectStudentPage(token: widget.token),
              ),
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () => Navigator.pushReplacementNamed(ctx, '/login'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        width: 160,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        leading: Builder(
          builder:
              (ctx) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
        ),
      ),
      drawer: Drawer(child: _buildMenu(context)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 600;
          return Row(
            children: [
              if (isDesktop)
                Container(
                  width: 220,
                  color: Colors.grey[200],
                  child: _buildMenu(context),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildStatCard(
                            "Total Students",
                            dashboardData['totalStudents'].toString(),
                            Colors.blue,
                          ),
                          _buildStatCard(
                            "Total Companies",
                            dashboardData['totalCompanies'].toString(),
                            Colors.green,
                          ),
                          _buildStatCard(
                            "Ongoing Drives",
                            dashboardData['ongoingDrives'].toString(),
                            Colors.orange,
                          ),
                          _buildStatCard(
                            "Placed Students",
                            dashboardData['placedStudents'].toString(),
                            Colors.purple,
                          ),
                          _buildStatCard(
                            "Placement %",
                            "${dashboardData['placementPercentage']}%",
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : (_error != null
                              ? Text('Error: $_error')
                              : _placements.isEmpty
                              ? Text('No placements found.')
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _placements.length,
                                itemBuilder: (ctx, i) {
                                  final p = _placements[i];
                                  return Card(
                                    child: ListTile(
                                      title: Text(p['title']),
                                      subtitle: Text(p['date']),
                                      onTap:
                                          () => Navigator.push(
                                            ctx,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => UpdatePlacementPage(
                                                    token: widget.token,
                                                    placement: p,
                                                  ),
                                            ),
                                          ).then((_) => _loadPlacements()),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog<
                                            bool
                                          >(
                                            context: ctx,
                                            builder:
                                                (_) => AlertDialog(
                                                  title: Text(
                                                    'Delete Placement',
                                                  ),
                                                  content: Text(
                                                    'Delete "${p['title']}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                          );
                                          if (confirm == true) {
                                            _deletePlacement(p['id']);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
