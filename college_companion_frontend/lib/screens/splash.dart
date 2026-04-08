import 'package:flutter/material.dart';
import 'auth_choice.dart';
import 'groups.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController.forward();
    _fadeController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              UserSession.isLoggedIn ? const GroupsPage() : const AuthChoice(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -60,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _scaleController,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppTheme.richBrown.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.golden.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Center Content
            Center(
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(_fadeController),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(
                    CurvedAnimation(
                      parent: _scaleController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [AppTheme.premiumShadow],
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 96,
                          color: AppTheme.cream,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // App Name
                      Text(
                        "College Companion",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        "Connect. Collaborate. Grow.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Loading Indicator
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          color: AppTheme.richBrown,
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
