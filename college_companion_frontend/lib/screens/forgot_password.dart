import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../session.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController _identifierController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
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
    _identifierController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordReset() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your roll number or email.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = await Api.resolveEmailForPasswordReset(identifier);
      if (email == null || email.isEmpty) {
        setState(
          () => _errorMessage =
              'No account found with that roll number or registered email.',
        );
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Sign out the user to force them to log back in with new password
      await FirebaseAuth.instance.signOut();

      // Clear user session
      UserSession.clear();

      setState(() => _emailSent = true);
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
                    'Password reset email sent',
                    style: TextStyle(color: AppTheme.cream),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(e.code));
    } catch (e) {
      setState(
        () => _errorMessage = 'An unexpected error occurred. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found for that roll number or email';
      case 'invalid-email':
        return 'Invalid email address associated with the provided identifier';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      default:
        return 'Failed to send password reset email. Please try again.';
    }
  }

  void _resetForm() {
    setState(() {
      _emailSent = false;
      _identifierController.clear();
      _errorMessage = null;
    });
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
            Icon(Icons.vpn_key_rounded, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            const Text('Reset Password'),
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
                  // Header
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
                          Icons.lock_open_rounded,
                          size: 72,
                          color: AppTheme.cream,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Forgot Your Password?",
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.cream,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We'll help you recover your account",
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.cream.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_emailSent)
                    _buildSuccessMessage(textTheme)
                  else
                    _buildPasswordResetForm(textTheme),

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text("Back to Sign In"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.richBrown, width: 2),
                      foregroundColor: AppTheme.richBrown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordResetForm(TextTheme textTheme) {
    return Card(
      elevation: 12,
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppTheme.golden.withOpacity(0.2), width: 1),
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
            Text(
              "Identify Your Account",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your roll number or registered email address",
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),

            // Input Field
            TextField(
              controller: _identifierController,
              decoration: InputDecoration(
                labelText: 'Roll Number or Email',
                hintText: 'e.g., 231210015 or name@college.edu',
                prefixIcon: const Icon(Icons.person_search_rounded),
                filled: true,
                fillColor: AppTheme.cream,
              ),
              keyboardType: TextInputType.text,
              enabled: !_isLoading,
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),

            // Send Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendPasswordReset,
              icon: _isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.mail_outline_rounded),
              label: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppTheme.cream,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text("Send Reset Link"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.richBrown,
                foregroundColor: AppTheme.cream,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 8,
                shadowColor: AppTheme.richBrown.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(TextTheme textTheme) {
    return Card(
      elevation: 12,
      shadowColor: Colors.green.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 56,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Email Sent Successfully!',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Check your registered email inbox for a password reset link. If you don\'t see it within a few minutes, please check your spam folder.',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
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
                      "The reset link expires in 1 hour",
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

            // Try Again Button
            TextButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
