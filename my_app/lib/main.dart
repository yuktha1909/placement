import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password.dart';
import 'reset_password_page.dart';
import 'user_dashboard_page.dart';
import 'view_placements_page.dart';
import 'update_placement_page.dart';
import 'add_student_page.dart';
import 'view_student_page.dart'; 
import 'update_status_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Placement System',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LandingPage());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());

          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

          case '/reset-password':
            final token = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => ResetPasswordPage(token: token));

          case '/user-dashboard':
            return MaterialPageRoute(builder: (_) => UserDashboardPage());

          case '/view-placements':
            final token = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => ViewPlacementsPage(token: token));

          case '/update-placement':
            final args = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (_) => UpdatePlacementPage(
                token: args['token'],
                placement: args['placement'],
              ),
            );

          case '/add-student':
            final token = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => AddStudentPage(token: token));

          case '/view-student':
            final token = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => ViewStudentsPage(token: token));

          case '/update-student':
            final args = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (_) => UpdateStatusScreen(
                studentId: args['studentId'] as int,
                token: args['token'],
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Page not found!')),
              ),
            );
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
