
import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password.dart';
import 'reset_password_page.dart';
import 'user_dashboard_page.dart';
import 'view_placements_page.dart';
import 'update_placement_page.dart';

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
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) => ResetPasswordPage(token: 'token-placeholder'),
        '/user-dashboard': (context) => UserDashboardPage(),
        '/view-placements': (context) {
          // This one can also be navigated manually if you need a token
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ViewPlacementsPage(token: args);
        },
         '/update-placement': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return UpdatePlacementPage(
            token: args['token'],
            placement: args['placement'],
          );
        },
      },
    );
  }
}
