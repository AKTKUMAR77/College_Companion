import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  String role = "student";
  final name = TextEditingController();
  final roll = TextEditingController();
  final email = TextEditingController();
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
    name.dispose();
    roll.dispose();
    email.dispose();
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
            Icon(
              Icons.app_registration_rounded,
              color: AppTheme.cream,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text("Sign Up"),
          ],
        ),
        backgroundColor: AppTheme.richBrown,
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: 20,
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(_fadeController),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                          Icons.person_add_rounded,
                          size: 72,
                          color: AppTheme.cream,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Create Your Account",
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cream,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join your campus community in seconds",
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.cream.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Form Card
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

                          // Full Name
                          _buildTextFieldWithIcon(
                            controller: name,
                            label: "Full Name",
                            icon: Icons.person_rounded,
                            hintText: "Enter your full name",
                          ),
                          const SizedBox(height: 16),

                          // Roll/Employee ID
                          _buildTextFieldWithIcon(
                            controller: roll,
                            label: role == "student"
                                ? "Roll Number"
                                : "Employee ID",
                            icon: role == "student"
                                ? Icons.badge_rounded
                                : Icons.work_outline_rounded,
                            hintText: role == "student"
                                ? "e.g., 231210015"
                                : "e.g., E12345",
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildTextFieldWithIcon(
                            controller: email,
                            label: "Email Address",
                            icon: Icons.email_rounded,
                            hintText: "yourname@college.edu",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password
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

                          // Info Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "A verification email will be sent. Please verify to complete signup.",
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Sign Up Button
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleSignUp,
                            icon: _isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Icons.check_circle_rounded),
                            label: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.cream,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text("Create Account"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.richBrown,
                              foregroundColor: AppTheme.cream,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 8,
                              shadowColor: AppTheme.richBrown.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),

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

                          // Sign In Button
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text("Already have an account?"),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
        labelText: "Create Password",
        hintText: "At least 8 characters",
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

  Future<void> _handleSignUp() async {
    if (name.text.isEmpty ||
        roll.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields.');
      return;
    }

    final normalizedEmail = email.text.trim();
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(normalizedEmail)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Api.signup(
        role,
        name.text,
        roll.text,
        normalizedEmail,
        password.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.cream,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Check your email to verify your account',
                    style: TextStyle(color: AppTheme.cream),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        setState(() => _errorMessage = message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
