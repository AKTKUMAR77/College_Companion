import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../session.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminCreateElectionScreen extends StatefulWidget {
  const AdminCreateElectionScreen({super.key});

  @override
  State<AdminCreateElectionScreen> createState() => _AdminCreateElectionScreenState();
}

class _AdminCreateElectionScreenState extends State<AdminCreateElectionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isUploading = false;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rulesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _endTime; // Optional specifically picking time for end

  // Targeting
  String _selectedYear = 'All';
  String _selectedBranch = 'All';
  String _selectedSemester = 'All';

  final List<String> _years = ['All', '1', '2', '3', '4'];
  final List<String> _branches = ['All', 'CSE', 'IT', 'ECE', 'EEE', 'MECH', 'CIVIL', 'AI', 'DS'];
  final List<String> _semesters = ['All', '1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primaryDark,
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.primaryDark,
                brightness: Brightness.light,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          final fullDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          if (isStart) {
            _startDate = fullDateTime;
          } else {
            _endDate = fullDateTime;
          }
        });
      }
    }
  }

  Future<void> _createElection() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select valid start and end dates.')));
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date cannot be before start date.')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      await Api.createElection(
        adminRoll: UserSession.rollNumber,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        branch: _selectedBranch,
        year: _selectedYear,
        semester: _selectedSemester,
        startDate: _startDate!,
        endDate: _endDate!,
        rules: _rulesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Election created successfully'), backgroundColor: Colors.green.shade700),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        title: const Text('Create CR Election'),
        backgroundColor: AppTheme.richBrown,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle('Election Details'),
              _buildTextField(_titleController, 'Election Title', Icons.title, maxLines: 1),
              const SizedBox(height: 12),
              _buildTextField(_descController, 'Description', Icons.description, maxLines: 3),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Target Audience'),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Year', _selectedYear, _years, (v) => setState(() => _selectedYear = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('Branch', _selectedBranch, _branches, (v) => setState(() => _selectedBranch = v!))),
                ],
              ),
              const SizedBox(height: 12),
              _buildDropdown('Semester', _selectedSemester, _semesters, (v) => setState(() => _selectedSemester = v!)),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Timeframe'),
              Row(
                children: [
                  Expanded(child: _buildDatePicker(true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDatePicker(false)),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Rules & Guidelines'),
              _buildTextField(_rulesController, 'Rules (e.g. No canvassing near booths...)', Icons.gavel, maxLines: 4, required: false),

              const SizedBox(height: 40),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _createElection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.richBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Icon(Icons.check_circle_outline, color: AppTheme.cream),
                  label: Text('Create Election', style: TextStyle(color: AppTheme.cream, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.richBrown),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool required = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.golden),
        filled: true,
        fillColor: AppTheme.cream,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.golden.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.golden.withOpacity(0.3))),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.cream,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.golden.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.golden.withOpacity(0.3))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    final text = date == null ? 'Select Time' : DateFormat('MMM dd, h:mm a').format(date);
    
    return InkWell(
      onTap: () => _pickDateTime(isStart),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.golden.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isStart ? 'Start Date' : 'End Date', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: AppTheme.richBrown),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark), overflow: TextOverflow.ellipsis)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
