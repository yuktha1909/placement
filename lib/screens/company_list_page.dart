import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Company {
  final String name;
  final String industry;
  final int openPositions;
  final String logo;
  final String location;
  final double rating;
  final String description;

  Company({
    required this.name,
    required this.industry,
    required this.openPositions,
    required this.logo,
    required this.location,
    required this.rating,
    required this.description,
  });
}

class CompanyListPage extends StatefulWidget {
  const CompanyListPage({super.key});

  @override
  State<CompanyListPage> createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedIndustry = 'All Industries';

  final List<String> _industries = [
    'All Industries',
    'Technology',
    'Finance',
    'Healthcare',
    'Manufacturing',
    'Consulting',
  ];

  // Sample company data
  final List<Company> _companies = [
    Company(
      name: 'Google',
      industry: 'Technology',
      openPositions: 5,
      logo: 'assets/logos/google.png',
      location: 'Mountain View, CA',
      rating: 4.8,
      description: 'Leading technology company specializing in search engine and cloud services.',
    ),
    Company(
      name: 'Microsoft',
      industry: 'Technology',
      openPositions: 3,
      logo: 'assets/logos/microsoft.png',
      location: 'Redmond, WA',
      rating: 4.6,
      description: 'Global technology corporation developing innovative software and hardware solutions.',
    ),
    Company(
      name: 'Morgan Stanley',
      industry: 'Finance',
      openPositions: 2,
      logo: 'assets/logos/morgan.png',
      location: 'New York, NY',
      rating: 4.5,
      description: 'Leading investment bank and financial services company.',
    ),
    Company(
      name: 'Johnson & Johnson',
      industry: 'Healthcare',
      openPositions: 4,
      logo: 'assets/logos/jnj.png',
      location: 'New Brunswick, NJ',
      rating: 4.3,
      description: 'Global leader in healthcare products and pharmaceuticals.',
    ),
    Company(
      name: 'Tata Consultancy Services',
      industry: 'Consulting',
      openPositions: 10,
      logo: 'assets/logos/tcs.png',
      location: 'Mumbai, India',
      rating: 4.2,
      description: 'Global leader in IT services, consulting, and business solutions.',
    ),
    Company(
      name: 'BMW',
      industry: 'Manufacturing',
      openPositions: 3,
      logo: 'assets/logos/bmw.png',
      location: 'Munich, Germany',
      rating: 4.7,
      description: 'Premium automobile and motorcycle manufacturer.',
    ),
  ];

  List<Company> get _filteredCompanies {
    return _companies.where((company) {
      // Filter by search query
      final nameMatches = company.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by industry
      final industryMatches = _selectedIndustry == 'All Industries' || 
                             company.industry == _selectedIndustry;
      
      return nameMatches && industryMatches;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddCompanyDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search companies...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
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
                const SizedBox(height: 10),
                
                // Industry filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedIndustry,
                      items: _industries.map((industry) {
                        return DropdownMenuItem<String>(
                          value: industry,
                          child: Text(industry),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedIndustry = value!;
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Company list
          Expanded(
            child: _filteredCompanies.isEmpty
                ? const Center(
                    child: Text(
                      'No companies found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCompanies.length,
                    itemBuilder: (context, index) {
                      final company = _filteredCompanies[index];
                      return _buildCompanyCard(company);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showCompanyDetails(company);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    company.name.substring(0, 1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Company info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            company.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                company.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.industry,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            company.location,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${company.openPositions} Open Positions',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
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

  void _showCompanyDetails(Company company) {
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
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Row(
                    children: [
                      // Fixed logo container size from 20x20 to 60x60
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child: Center(
                          child: Text(
                            company.name.substring(0, 1),
                            style: TextStyle(
                              fontSize: 24, // Reduced from 28 to match proper proportions
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              company.industry,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    company.location,
                                    style: TextStyle(color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Added close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Company Rating: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        company.rating.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Company Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                company.description,
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Positions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${company.openPositions} Openings',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: 3, // Showing sample positions
                  itemBuilder: (context, index) {
                    final positions = [
                      'Software Engineer',
                      'Product Manager',
                      'Data Analyst',
                    ];
                    final departments = [
                      'Engineering',
                      'Product',
                      'Analytics',
                    ];
                    
                    if (index < positions.length) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(positions[index]),
                          subtitle: Text(departments[index]),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Handle application
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Applied for ${positions[index]} position'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCompanyDialog() {
    final nameController = TextEditingController();
    String selectedIndustry = _industries[1]; // Default to first real industry
    final locationController = TextEditingController();
    final positionsController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Company'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Industry',
                      prefixIcon: Icon(Icons.category),
                    ),
                    value: selectedIndustry,
                    items: _industries
                        .where((industry) => industry != 'All Industries')
                        .map((industry) {
                          return DropdownMenuItem<String>(
                            value: industry,
                            child: Text(industry),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedIndustry = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an industry';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: positionsController,
                    decoration: const InputDecoration(
                      labelText: 'Open Positions',
                      prefixIcon: Icon(Icons.work),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of open positions';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                // Validate and add company
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _companies.add(
                      Company(
                        name: nameController.text,
                        industry: selectedIndustry,
                        openPositions: int.parse(positionsController.text),
                        logo: 'assets/logos/default.png',
                        location: locationController.text,
                        rating: 4.0,
                        description: descriptionController.text,
                      ),
                    );
                  });
                  
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Company added successfully'),
                      backgroundColor: Colors.green,
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