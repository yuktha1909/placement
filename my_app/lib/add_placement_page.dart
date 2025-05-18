import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPlacementPage extends StatefulWidget {
  final String token;
  const AddPlacementPage({Key? key, required this.token}) : super(key: key);

  @override
  _AddPlacementPageState createState() => _AddPlacementPageState();
}

class _AddPlacementPageState extends State<AddPlacementPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String title = '';
  String date = '';
  String company = '';
  String location = '';
  String packageOffer = '';
  String eligibility = '';
  String deadline = '';
  String description = '';

  String? validateDate(String? value) {
    final pattern = r'^\d{4}-\d{2}-\d{2}$';
    final regExp = RegExp(pattern);
    if (value == null || !regExp.hasMatch(value)) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    return null;
  }

  Future<void> addPlacement() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://localhost:5000/placements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'title': title,
        'date': date,
        'company': company,
        'location': location,
        'package': packageOffer,
        'eligibility': eligibility,
        'deadline': deadline,
        'description': description,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Placement added successfully')),
      );
      Navigator.pop(context);
    } else if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bad request. Check all fields.')),
      );
    } else if (response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access denied. Admins only.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${response.statusCode}: ${response.body}')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: onChanged,
        validator: validator ?? (val) => val == null || val.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Placement")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(label: 'Title', onChanged: (v) => title = v),
                    _buildTextField(
                      label: 'Date (YYYY-MM-DD)',
                      onChanged: (v) => date = v,
                      validator: validateDate,
                    ),
                    _buildTextField(label: 'Company Name', onChanged: (v) => company = v),
                    _buildTextField(label: 'Location', onChanged: (v) => location = v),
                    _buildTextField(label: 'Package (e.g. 6 LPA)', onChanged: (v) => packageOffer = v),
                    _buildTextField(label: 'Eligibility Criteria', onChanged: (v) => eligibility = v),
                    _buildTextField(
                      label: 'Application Deadline (YYYY-MM-DD)',
                      onChanged: (v) => deadline = v,
                      validator: validateDate,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        onChanged: (v) => description = v,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter Description' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addPlacement();
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
