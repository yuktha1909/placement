import 'package:flutter/material.dart';
import '../widgets/student_filter.dart';


class Student {
  final String id;
  final String name;
  final String email;
  final String course;
  final String semester;
  final double cgpa;
  final String photoUrl;
  final List<String> skills;
  final PlacementStatus status;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.course,
    required this.semester,
    required this.cgpa,
    required this.photoUrl,
    required this.skills,
    required this.status,
  });
}

enum PlacementStatus {
  notPlaced,
  inProcess,
  placed,
}

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _selectedCourses = [];
  List<String> _selectedStatuses = [];
  double _minCGPA = 0.0;

  // Sample student data
  final List<Student> _students = [
    Student(
      id: "STU001",
      name: "Rahul Sharma",
      email: "rahul.s@college.edu",
      course: "Computer Science",
      semester: "7th",
      cgpa: 8.7,
      photoUrl: "assets/images/student1.jpg",
      skills: ["Java", "Python", "Machine Learning"],
      status: PlacementStatus.placed,
    ),
    Student(
      id: "STU002",
      name: "Priya Patel",
      email: "priya.p@college.edu",
      course: "Information Technology",
      semester: "7th",
      cgpa: 9.2,
      photoUrl: "assets/images/student2.jpg",
      skills: ["C++", "React", "Web Development"],
      status: PlacementStatus.placed,
    ),
    Student(
      id: "STU003",
      name: "Amit Kumar",
      email: "amit.k@college.edu",
      course: "Computer Science",
      semester: "7th",
      cgpa: 7.9,
      photoUrl: "assets/images/student3.jpg",
      skills: ["Python", "Data Science", "SQL"],
      status: PlacementStatus.inProcess,
    ),
    Student(
      id: "STU004",
      name: "Neha Singh",
      email: "neha.s@college.edu",
      course: "Electronics",
      semester: "7th",
      cgpa: 8.5,
      photoUrl: "assets/images/student4.jpg",
      skills: ["VLSI", "Embedded Systems", "IoT"],
      status: PlacementStatus.notPlaced,
    ),
    Student(
      id: "STU005",
      name: "Vikram Desai",
      email: "vikram.d@college.edu",
      course: "Mechanical",
      semester: "7th",
      cgpa: 8.1,
      photoUrl: "assets/images/student5.jpg",
      skills: ["AutoCAD", "SolidWorks", "Project Management"],
      status: PlacementStatus.inProcess,
    ),
    Student(
      id: "STU006",
      name: "Ananya Reddy",
      email: "ananya.r@college.edu",
      course: "Information Technology",
      semester: "7th",
      cgpa: 9.0,
      photoUrl: "assets/images/student6.jpg",
      skills: ["JavaScript", "Node.js", "MongoDB"],
      status: PlacementStatus.placed,
    ),
  ];

  List<Student> get _filteredStudents {
    return _students.where((student) {
      // Filter by search query (name or ID)
      final nameMatches = student.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final idMatches = student.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by course
      final courseMatches = _selectedCourses.isEmpty || 
                           _selectedCourses.contains(student.course);
      
      // Filter by status
      final statusMatches = _selectedStatuses.isEmpty || 
                           _selectedStatuses.contains(_getStatusString(student.status));
      
      // Filter by CGPA
      final cgpaMatches = student.cgpa >= _minCGPA;
      
      return (nameMatches || idMatches) && courseMatches && statusMatches && cgpaMatches;
    }).toList();
  }

  List<String> get _courses {
    final courses = _students.map((student) => student.course).toSet().toList();
    courses.sort();
    return courses;
  }

  String _getStatusString(PlacementStatus status) {
    switch (status) {
      case PlacementStatus.notPlaced:
        return 'Not Placed';
      case PlacementStatus.inProcess:
        return 'In Process';
      case PlacementStatus.placed:
        return 'Placed';
      default:
        return '';
    }
  }

  Color _getStatusColor(PlacementStatus status) {
    switch (status) {
      case PlacementStatus.notPlaced:
        return Colors.red[100]!;
      case PlacementStatus.inProcess:
        return Colors.amber[100]!;
      case PlacementStatus.placed:
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(PlacementStatus status) {
    switch (status) {
      case PlacementStatus.notPlaced:
        return Colors.red[800]!;
      case PlacementStatus.inProcess:
        return Colors.amber[800]!;
      case PlacementStatus.placed:
        return Colors.green[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StudentFilter(
          courses: _courses,
          selectedCourses: _selectedCourses,
          selectedStatuses: _selectedStatuses,
          minCGPA: _minCGPA,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCourses = result['courses'];
        _selectedStatuses = result['statuses'];
        _minCGPA = result['minCGPA'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddStudentDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or ID...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                
                // Filter button
                InkWell(
                  onTap: _showFilterDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: Colors.blue[800],
                          size: 24,
                        ),
                        if (_selectedCourses.isNotEmpty || 
                            _selectedStatuses.isNotEmpty || 
                            _minCGPA > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters applied
          if (_selectedCourses.isNotEmpty || _selectedStatuses.isNotEmpty || _minCGPA > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...(_selectedCourses.map((course) => _buildFilterChip(course, () {
                      setState(() {
                        _selectedCourses.remove(course);
                      });
                    }))),
                    ...(_selectedStatuses.map((status) => _buildFilterChip(status, () {
                      setState(() {
                        _selectedStatuses.remove(status);
                      });
                    }))),
                    if (_minCGPA > 0)
                      _buildFilterChip('CGPA ≥ ${_minCGPA.toStringAsFixed(1)}', () {
                        setState(() {
                          _minCGPA = 0.0;
                        });
                      }),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCourses = [];
                          _selectedStatuses = [];
                          _minCGPA = 0.0;
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Student list
          Expanded(
            child: _filteredStudents.isEmpty
                ? const Center(
                    child: Text(
                      'No students found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return _buildStudentCard(student);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showStudentDetails(student);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student photo
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: Text(
                  student.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.id,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.course} | ${student.semester} Semester',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          student.email,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'CGPA: ${student.cgpa.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(student.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusString(student.status),
                            style: TextStyle(
                              color: _getStatusTextColor(student.status),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      student.name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.id,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              student.email,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Academic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem('Course', student.course),
                      _buildInfoItem('Semester', student.semester),
                      _buildInfoItem('CGPA', student.cgpa.toStringAsFixed(1)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(student.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusString(student.status),
                      style: TextStyle(
                        color: _getStatusTextColor(student.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Skills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: student.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: Colors.blue[800],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Placement History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: student.status == PlacementStatus.placed
                    ? Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[50],
                            child: Icon(Icons.business, color: Colors.blue[800]),
                          ),
                          title: const Text('Google'),
                          subtitle: const Text('Software Engineer\nJoining: June 2025'),
                          isThreeLine: true,
                        ),
                      )
                    : student.status == PlacementStatus.inProcess
                        ? ListView(
                            children: [
                              Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.amber[50],
                                    child: Icon(Icons.access_time, color: Colors.amber[800]),
                                  ),
                                  title: const Text('Microsoft'),
                                  subtitle: const Text('Technical Interview scheduled on 10th May, 2025'),
                                ),
                              ),
                              Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green[50],
                                    child: Icon(Icons.check_circle, color: Colors.green[800]),
                                  ),
                                  title: const Text('Amazon'),
                                  subtitle: const Text('Aptitude Test cleared, waiting for interview'),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              'No placement activities yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle update status
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/update_status', arguments: student);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Update Status'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final idController = TextEditingController();
    final courseController = TextEditingController();
    final semesterController = TextEditingController();
    final cgpaController = TextEditingController();
    final skillsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cgpaController,
                  decoration: const InputDecoration(
                    labelText: 'CGPA',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Skills (comma separated)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate and add student
                if (nameController.text.isNotEmpty && 
                    idController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    courseController.text.isNotEmpty &&
                    semesterController.text.isNotEmpty &&
                    cgpaController.text.isNotEmpty) {
                  
                  setState(() {
                    _students.add(
                      Student(
                        id: idController.text,
                        name: nameController.text,
                        email: emailController.text,
                        course: courseController.text,
                        semester: semesterController.text,
                        cgpa: double.tryParse(cgpaController.text) ?? 0.0,
                        photoUrl: 'assets/images/default.jpg',
                        skills: skillsController.text.split(',')
                            .map((skill) => skill.trim())
                            .where((skill) => skill.isNotEmpty)
                            .toList(),
                        status: PlacementStatus.notPlaced,
                      ),
                    );
                  });
                  
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}