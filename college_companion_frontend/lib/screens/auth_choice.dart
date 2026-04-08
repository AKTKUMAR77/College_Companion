import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthChoice extends StatefulWidget {
  const AuthChoice({super.key});

  @override
  State<AuthChoice> createState() => _AuthChoiceState();
}

class _AuthChoiceState extends State<AuthChoice> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                FadeTransition(
                  opacity: Tween<double>(
                    begin: 0,
                    end: 1,
                  ).animate(_fadeController),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_slideController),
                    child: Column(
                      children: [
                        // Top Logo Section
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [AppTheme.premiumShadow],
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: AppTheme.cream,
                            size: 72,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // App Name
                        Text(
                          'College Companion',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                            fontSize: 36,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Tagline
                        Text(
                          'Your central hub for academics, groups, and campus collaboration',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textMuted,
                            height: 1.5,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Buttons Section
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(_slideController),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sign In Button
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, "/signin"),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text("Sign In"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.richBrown,
                          foregroundColor: AppTheme.cream,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 8,
                          shadowColor: AppTheme.richBrown.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Create Account Button
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, "/signup"),
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text("Create Account"),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.richBrown, width: 2),
                          foregroundColor: AppTheme.richBrown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Footer Text
                Center(
                  child: Text(
                    'Connect. Collaborate. Succeed.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.golden,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
