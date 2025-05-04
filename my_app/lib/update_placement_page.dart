// File: lib/update_placement_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdatePlacementPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> placement;

  const UpdatePlacementPage({
    Key? key,
    required this.token,
    required this.placement,
  }) : super(key: key);

  @override
  State<UpdatePlacementPage> createState() => _UpdatePlacementPageState();
}

class _UpdatePlacementPageState extends State<UpdatePlacementPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _packageCtrl;
  late TextEditingController _eligibilityCtrl;
  late TextEditingController _deadlineCtrl;
  late TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.placement;
    _titleCtrl       = TextEditingController(text: p['title'] ?? '');
    _dateCtrl        = TextEditingController(text: p['date'] ?? '');
    _companyCtrl     = TextEditingController(text: p['company'] ?? '');
    _locationCtrl    = TextEditingController(text: p['location'] ?? '');
    _packageCtrl     = TextEditingController(text: p['package'] ?? '');
    _eligibilityCtrl = TextEditingController(text: p['eligibility'] ?? '');
    _deadlineCtrl    = TextEditingController(text: p['deadline'] ?? '');
    _descriptionCtrl = TextEditingController(text: p['description'] ?? '');
  }

  Future<void> _updatePlacement() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'title':       _titleCtrl.text,
      'date':        _dateCtrl.text,
      'company':     _companyCtrl.text,
      'location':    _locationCtrl.text,
      'package':     _packageCtrl.text,
      'eligibility': _eligibilityCtrl.text,
      'deadline':    _deadlineCtrl.text,
      'description': _descriptionCtrl.text,
    };

    final resp = await http.put(
      Uri.parse('http://localhost:5000/placements/${widget.placement['id']}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      Navigator.pop(context, true);    // you can return a flag for refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update placement: ${resp.body}')),
      );
    }
  }

  Future<void> _deletePlacement() async {
    final resp = await http.delete(
      Uri.parse('http://localhost:5000/placements/${widget.placement['id']}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (resp.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete placement')),
      );
    }
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator ??
            (v) => (v == null || v.isEmpty) ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update / Delete Placement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('Title', _titleCtrl),
              _buildField('Date (YYYY-MM-DD)', _dateCtrl, validator: (v) {
                final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                return (v != null && pattern.hasMatch(v))
                    ? null
                    : 'Enter valid date';
              }),
              _buildField('Company', _companyCtrl),
              _buildField('Location', _locationCtrl),
              _buildField('Package (e.g. 6 LPA)', _packageCtrl),
              _buildField('Eligibility', _eligibilityCtrl),
              _buildField('Deadline (YYYY-MM-DD)', _deadlineCtrl, validator: (v) {
                final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                return (v != null && pattern.hasMatch(v))
                    ? null
                    : 'Enter valid date';
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updatePlacement,
                child: const Text('Update'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text('Delete this placement?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) _deletePlacement();
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
