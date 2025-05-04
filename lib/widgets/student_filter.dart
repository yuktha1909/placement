import 'package:flutter/material.dart';


class StudentFilter extends StatefulWidget {
  final List<String> courses;
  final List<String> selectedCourses;
  final List<String> selectedStatuses;
  final double minCGPA;

  const StudentFilter({
    super.key,
    required this.courses,
    required this.selectedCourses,
    required this.selectedStatuses,
    required this.minCGPA,
  });

  @override
  State<StudentFilter> createState() => _StudentFilterState();
}

class _StudentFilterState extends State<StudentFilter> {
  late List<String> _selectedCourses;
  late List<String> _selectedStatuses;
  late double _minCGPA;

  @override
  void initState() {
    super.initState();
    _selectedCourses = List.from(widget.selectedCourses);
    _selectedStatuses = List.from(widget.selectedStatuses);
    _minCGPA = widget.minCGPA;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Students',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Course Filter
          const Text('Course'),
          Wrap(
            spacing: 8,
            children: widget.courses.map((course) {
              final isSelected = _selectedCourses.contains(course);
              return FilterChip(
                label: Text(course),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selected ? _selectedCourses.add(course) : _selectedCourses.remove(course);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Placement Status Filter
          const Text('Placement Status'),
          Wrap(
            spacing: 8,
            children: ['Not Placed', 'In Process', 'Placed'].map((status) {
              final isSelected = _selectedStatuses.contains(status);
              return FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selected ? _selectedStatuses.add(status) : _selectedStatuses.remove(status);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // CGPA Filter
          const Text('Minimum CGPA'),
          Slider(
            value: _minCGPA,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            label: _minCGPA.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _minCGPA = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'courses': _selectedCourses,
                  'statuses': _selectedStatuses,
                  'minCGPA': _minCGPA,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
