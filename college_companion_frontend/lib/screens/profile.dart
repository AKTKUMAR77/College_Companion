import 'package:flutter/material.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0xFFEAF2FF),
                  child: Icon(Icons.person_rounded, size: 38, color: AppTheme.brandBlue),
                ),
                const SizedBox(height: 16),
                Text(
                  UserSession.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: ${UserSession.rollNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
