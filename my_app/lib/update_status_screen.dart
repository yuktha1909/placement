import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateStatusScreen extends StatefulWidget {
  final int studentId;
  final String token;

  const UpdateStatusScreen({
    Key? key,
    required this.studentId,
    required this.token,
  }) : super(key: key);

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  final List<String> _statusOptions = ['Placed', 'Rejected', 'Pending'];
  String? _selectedStatus;
  bool _isLoading = false;
  String? _message;

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) {
      setState(() {
        _message = 'Please select a status.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final url = Uri.parse(
      'http://192.168.175.14:5000/students/${widget.studentId}/status',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': _selectedStatus}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          _message = 'Status updated successfully.';
          _selectedStatus = null;
        });
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to update status.';
        setState(() {
          _message = 'Error: $error';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Student Status')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Select New Status", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items:
                  _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _updateStatus,
                  child: const Text('Update Status'),
                ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color:
                      _message!.toLowerCase().contains('error')
                          ? Colors.red
                          : Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
