import 'package:flutter/material.dart';
import 'screens/admin_dashboard.dart';
import 'screens/company_list_page.dart';
import 'screens/student_list_page.dart';
import 'screens/update_status_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Placement App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
      routes: {
        '/dashboard': (context) => const AdminDashboard(),
        '/company_list': (context) => const CompanyListPage(),
        '/student_list': (context) => const StudentListPage(),
        '/update_status': (context) => const UpdateStatusPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _widgetOptions = <Widget>[
    const AdminDashboard(),
    const StudentListPage(),
    const CompanyListPage(),
    const UpdateStatusPage(),
  ];

  static final List<String> _pageTitles = [
    'Dashboard',
    'Students',
    'Companies',
    'Update Status',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Placement Admin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          NavigationDrawerDestination(
            icon: const Icon(Icons.dashboard),
            label: Text(_pageTitles[0]),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.people),
            label: Text(_pageTitles[1]),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.business),
            label: Text(_pageTitles[2]),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.update),
            label: Text(_pageTitles[3]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 10, 16, 10),
            child: Text('Other'),
          ),
          // Replace NavigationDrawerDestination with a ListTile for settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Close drawer
                Navigator.pop(context);
                // Navigate to settings or show settings dialog
                // TODO: Implement settings navigation
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: _pageTitles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: _pageTitles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.business_outlined),
            selectedIcon: const Icon(Icons.business),
            label: _pageTitles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.update_outlined),
            selectedIcon: const Icon(Icons.update),
            label: _pageTitles[3],
          ),
        ],
      ),
    );
  }
}