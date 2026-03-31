import 'package:flutter/material.dart';
import 'screens/splash.dart';
import 'screens/login.dart';
import 'screens/groups.dart';
import 'screens/auth_choice.dart';
import 'screens/signin.dart';
import 'screens/signup.dart';
import 'screens/pyq.dart';
import 'screens/clubs.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CollegeCompanionApp());
}

class CollegeCompanionApp extends StatelessWidget {
  const CollegeCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College Companion',
      theme: AppTheme.lightTheme,

      // 👇 Start here
      home: const SplashScreen(),

      // 👇 Named routes for clean navigation
      routes: {
        '/login': (context) => LoginPage(),
        '/groups': (context) => const GroupsPage(),
        '/auth_choice': (context) => const AuthChoice(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/pyq': (context) => const PyqPage(),
        '/clubs': (context) => const ClubsScreen(),
      },
    );
  }
}
