import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacementEventsPage extends StatefulWidget {
  final String token;

  PlacementEventsPage({required this.token});

  @override
  _PlacementEventsPageState createState() => _PlacementEventsPageState();
}

class _PlacementEventsPageState extends State<PlacementEventsPage> {
  late Future<List<dynamic>> placementEvents;

  Future<List<dynamic>> fetchPlacementEvents() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/placements'),
      headers: {
        'Authorization':
            'Bearer ${widget.token}', // Pass JWT token for authentication
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['placements'];
    } else {
      throw Exception('Failed to load placement events');
    }
  }

  @override
  void initState() {
    super.initState();
    placementEvents = fetchPlacementEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Placement Events')),
      body: FutureBuilder<List<dynamic>>(
        future: placementEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No placement events available.'));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event['title']),
                  subtitle: Text(event['date']),
                  onTap: () {
                    // Navigate to update placement page if needed
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
