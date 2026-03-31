import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF2FF), Color(0xFFF8FFFD)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        size: 68,
                        color: AppTheme.brandBlue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'College Companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textStrong,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Continue with the updated sign in flow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blueGrey.shade700),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/signin'),
                        child: const Text('Go to Sign In'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
