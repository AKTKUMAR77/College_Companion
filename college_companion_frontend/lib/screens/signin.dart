import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  String role = "student";
  final roll = TextEditingController();
  final password = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    roll.dispose();
    password.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.school_rounded, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            const Text("College Companion"),
          ],
        ),
        backgroundColor: AppTheme.richBrown,
        elevation: 8,
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: 24,
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(_fadeController),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Welcome Header
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [AppTheme.premiumShadow],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_circle_rounded,
                          size: 72,
                          color: AppTheme.cream,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Welcome Back",
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cream,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to your campus network",
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.cream.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign In Form Card
                  Card(
                    elevation: 12,
                    shadowColor: AppTheme.shadowColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: AppTheme.golden.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppTheme.lightCream,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role Selection
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.golden.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.golden.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  color: AppTheme.richBrown,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "I am a",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cream,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.golden.withOpacity(0.5),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: role,
                                        isExpanded: true,
                                        borderRadius: BorderRadius.circular(12),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.richBrown,
                                        ),
                                        icon: Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color: AppTheme.richBrown,
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: "student",
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.school,
                                                  size: 18,
                                                  color: AppTheme.richBrown,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text("Student"),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: "faculty",
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.work,
                                                  size: 18,
                                                  color: AppTheme.richBrown,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text("Faculty"),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) =>
                                            setState(() => role = v!),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Roll/Employee ID Field
                          _buildTextFieldWithIcon(
                            controller: roll,
                            label: role == "student"
                                ? "Roll Number"
                                : "Employee ID",
                            icon: role == "student"
                                ? Icons.badge_rounded
                                : Icons.work_outline_rounded,
                            hintText: role == "student"
                                ? "Enter your roll number"
                                : "Enter your employee ID",
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildPasswordField(),
                          const SizedBox(height: 28),

                          // Error Message
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_errorMessage != null) const SizedBox(height: 16),

                          // Sign In Button
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleSignIn,
                            icon: _isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Icons.login_rounded),
                            label: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.cream,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text("Sign In"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.richBrown,
                              foregroundColor: AppTheme.cream,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 8,
                              shadowColor: AppTheme.richBrown.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password Button
                          TextButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    "/forgot_password",
                                  ),
                            icon: Icon(
                              Icons.lock_reset_rounded,
                              color: AppTheme.accentGold,
                              size: 20,
                            ),
                            label: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppTheme.golden.withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppTheme.golden.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Create Account Button
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, "/signup"),
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text("Create New Account"),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppTheme.richBrown,
                                width: 2,
                              ),
                              foregroundColor: AppTheme.richBrown,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppTheme.cream,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: password,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        prefixIcon: const Icon(Icons.lock_rounded),
        filled: true,
        fillColor: AppTheme.cream,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: AppTheme.richBrown,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final enteredRoll = roll.text.trim();
    final enteredPassword = password.text;

    if (enteredRoll.isEmpty || enteredPassword.isEmpty) {
      setState(
        () => _errorMessage = 'Please enter both roll number and password.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await Api.login(role, enteredRoll, enteredPassword);
      UserSession.setSession(
        userName: data["name"],
        rollNumber: data["roll"],
        userRole: data["role"] ?? role,
        admin: data["is_admin"] == true,
        cr: data["is_cr"] == true,
        userGroups: List<String>.from(data["groups"]),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/groups");
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        setState(() => _errorMessage = message.replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
