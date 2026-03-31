import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthChoice extends StatelessWidget {
  const AuthChoice({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brandBlue.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.brandBlue, AppTheme.brandSky],
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'College Companion',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textStrong,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your central hub for academics, groups, and campus collaboration.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.blueGrey.shade700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        child: const Text("Sign In"),
                        onPressed: () => Navigator.pushNamed(context, "/signin"),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        child: const Text("Create Account"),
                        onPressed: () => Navigator.pushNamed(context, "/signup"),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
