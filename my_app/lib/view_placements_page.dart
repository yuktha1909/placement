// File: lib/view_placements_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ViewPlacementsPage extends StatelessWidget {
  final String token;
  const ViewPlacementsPage({Key? key, required this.token}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchPlacements() async {
    final response = await http.get(
      Uri.parse('http://192.168.175.14:5000/placements'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch placements');
    }
    final List raw = jsonDecode(response.body)['placements'];
    return raw.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  String _formatDate(String raw) {
    try {
      final parts = raw.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      final dt = DateTime(y, m, d);
      return DateFormat.yMMMMd().format(dt);  // e.g. May 4, 2025
    } catch (_) {
      return raw; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Placements")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPlacements(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final placements = snap.data!;
          if (placements.isEmpty) {
            return const Center(child: Text('No placements found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: placements.length,
            itemBuilder: (ctx, i) {
              final p = placements[i];
              final title = p['title'] ?? '—';
              final rawDate = p['date'] ?? '';
              final formatted = rawDate.isNotEmpty ? _formatDate(rawDate) : '—';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(formatted),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/update-placement',
                        arguments: {
                          'token': token,
                          'placement': p,
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
