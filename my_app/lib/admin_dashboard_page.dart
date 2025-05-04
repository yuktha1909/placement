// File: lib/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your existing pages
import 'add_placement_page.dart';
import 'view_placements_page.dart';
import 'update_placement_page.dart';
import 'placement_events_page.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPlacements();
  }

  Future<void> _loadPlacements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp = await http.get(
        Uri.parse('http://localhost:5000/placements'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['placements'] as List;
        setState(() {
          _placements = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        throw Exception('Server returned ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
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
        Uri.parse('http://localhost:5000/placements/$id'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200) {
        setState(() {
          _placements.removeWhere((p) => p['id'] == id);
        });
      } else {
        throw Exception('Delete failed: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting: $e')),
      );
    }
  }

  Widget _buildMenu(BuildContext ctx) {
    return ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Placement'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => AddPlacementPage(token: widget.token)),
            ).then((_) => _loadPlacements());
          },
        ),
        ListTile(
          leading: Icon(Icons.list),
          title: Text('View Placements'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => ViewPlacementsPage(token: widget.token)),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.event),
          title: Text('Placement Events'),
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => PlacementEventsPage(token: widget.token)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        leading: Builder(
          builder: (ctx) => IconButton(
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
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (_error != null
                        ? Center(child: Text('Error: $_error'))
                        : (_placements.isEmpty
                            ? Center(child: Text('No placements found.'))
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _placements.length,
                                itemBuilder: (ctx, i) {
                                  final p = _placements[i];
                                  return Card(
                                    child: ListTile(
                                      title: Text(p['title']),
                                      subtitle: Text(p['date']),
                                      onTap: () => Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) => UpdatePlacementPage(
                                            token: widget.token,
                                            placement: p,
                                          ),
                                        ),
                                      ).then((_) => _loadPlacements()),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: ctx,
                                            builder: (_) => AlertDialog(
                                              title: Text('Delete Placement'),
                                              content: Text('Delete "${p['title']}"?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () => Navigator.pop(ctx, false),
                                                    child: Text('Cancel')),
                                                TextButton(
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    child: Text('Delete')),
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
                              ))),
              ),
            ],
          );
        },
      ),
    );
  }
}
