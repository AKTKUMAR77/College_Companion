import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _studentData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchStudent() async {
    final rollNumber = _searchController.text.trim();
    if (rollNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a roll number';
        _studentData = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await Api.searchStudentByRoll(rollNumber);
      setState(() {
        _studentData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _studentData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStudent() async {
    if (_studentData == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Api.updateStudentDetails(
        rollNumber: _studentData!['roll'],
        email: _studentData!['email'],
        password: _studentData!['new_password'],
        emailVerified: _studentData!['email_verified'] ?? false,
        isCr: _studentData!['is_cr'] ?? false,
      );

      // Refresh student data
      await _searchStudent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student details updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!UserSession.isAdmin) {
      return Scaffold(
        body: Center(
          child: Text(
            'Access Denied: Admin privileges required',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            const Text('Admin Panel'),
          ],
        ),
        backgroundColor: AppTheme.richBrown,
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                shadowColor: AppTheme.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/elections'),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.how_to_vote, size: 40, color: AppTheme.cream),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Election Management', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.cream)),
                              Text('Create and monitor CR elections', style: TextStyle(color: AppTheme.cream.withOpacity(0.9))),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: AppTheme.cream),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search Section
              Card(
                elevation: 8,
                shadowColor: AppTheme.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppTheme.lightCream,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Student',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Roll Number',
                          hintText: 'Enter student roll number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _searchStudent(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _searchStudent,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: const Text('Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.richBrown,
                            foregroundColor: AppTheme.cream,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Student Details Section
              if (_studentData != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 8,
                  shadowColor: AppTheme.shadowColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppTheme.lightCream,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Details',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                        ),
                        const SizedBox(height: 20),

                        // Read-only fields
                        _buildDetailRow('Name', _studentData!['name']),
                        _buildDetailRow('Roll Number', _studentData!['roll']),
                        _buildDetailRow('Role', _studentData!['role']),
                        _buildDetailRow(
                          'Created At',
                          _studentData!['created_at'],
                        ),

                        const SizedBox(height: 20),

                        // Editable fields
                        TextFormField(
                          initialValue: _studentData!['email'],
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter email address',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _studentData!['email'] = value.trim();
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText:
                                'New Password (leave empty to keep current)',
                            hintText: 'Enter new password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            _studentData!['new_password'] = value;
                          },
                        ),

                        const SizedBox(height: 16),

                        CheckboxListTile(
                          title: const Text('Email Verified'),
                          value: _studentData!['email_verified'] ?? false,
                          onChanged: (value) {
                            setState(() {
                              _studentData!['email_verified'] = value ?? false;
                            });
                          },
                          activeColor: AppTheme.richBrown,
                        ),

                        if (_studentData!['role'] == 'student')
                          CheckboxListTile(
                            title: const Text('Class Representative (CR)'),
                            subtitle: const Text('Grants ability to post in Announcements and Notes groups'),
                            value: _studentData!['is_cr'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _studentData!['is_cr'] = value ?? false;
                              });
                            },
                            activeColor: AppTheme.richBrown,
                          ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _updateStudent,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text('Update Student Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.richBrown,
                              foregroundColor: AppTheme.cream,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }
}
