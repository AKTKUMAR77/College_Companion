import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class PyqPage extends StatefulWidget {
  const PyqPage({super.key});

  @override
  State<PyqPage> createState() => _PyqPageState();
}

class _PyqPageState extends State<PyqPage> with TickerProviderStateMixin {
  List<String> _years = [];
  List<String> _branches = [];
  List<String> _semesters = [];

  String? _selectedYear;
  String? _selectedBranch;
  String? _selectedSemester;

  bool _isLoadingOptions = true;
  bool _isLoadingPapers = false;
  List<Map<String, dynamic>> _papers = [];
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
    _loadOptions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() => _isLoadingOptions = true);

    try {
      final options = await Api.fetchPyqOptions();
      final years = List<String>.from(options['years'] ?? []);
      final branches = List<String>.from(options['branches'] ?? []);
      final semesters = List<String>.from(options['semesters'] ?? []);

      setState(() {
        _years = years;
        _branches = branches;
        _semesters = semesters;
        _selectedYear = years.isNotEmpty ? years.first : null;
        _selectedBranch = branches.isNotEmpty ? branches.first : null;
        _selectedSemester = semesters.isNotEmpty ? semesters.first : null;
      });

      await _loadPapers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load PYQ options: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingOptions = false);
    }
  }

  Future<void> _loadPapers() async {
    if (_selectedYear == null ||
        _selectedBranch == null ||
        _selectedSemester == null)
      return;

    setState(() => _isLoadingPapers = true);

    try {
      final papers = await Api.fetchPyqs(
        year: _selectedYear!,
        branch: _selectedBranch!,
        semester: _selectedSemester!,
      );

      if (!mounted) return;
      setState(() => _papers = papers);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load papers: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingPapers = false);
    }
  }

  Future<void> _openDriveLink(String link) async {
    final url = Uri.tryParse(link);
    if (url == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid drive link.')));
      return;
    }

    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open drive link.')),
      );
    }
  }

  Future<void> _showUploadDialog() async {
    String year = _selectedYear ?? (_years.isNotEmpty ? _years.first : '');
    String branch =
        _selectedBranch ?? (_branches.isNotEmpty ? _branches.first : '');
    String semester =
        _selectedSemester ?? (_semesters.isNotEmpty ? _semesters.first : '');
    final subjectController = TextEditingController();
    final driveLinkController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        bool uploading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.upload_rounded, color: AppTheme.richBrown),
                  const SizedBox(width: 12),
                  const Text('Upload PYQ'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: year.isNotEmpty ? year : null,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        prefixIcon: Icon(Icons.calendar_month_rounded),
                      ),
                      items: _years
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => year = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: branch.isNotEmpty ? branch : null,
                      decoration: const InputDecoration(
                        labelText: 'Branch',
                        prefixIcon: Icon(Icons.school_rounded),
                      ),
                      items: _branches
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => branch = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: semester.isNotEmpty ? semester : null,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        prefixIcon: Icon(Icons.layers_rounded),
                      ),
                      items: _semesters
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null)
                          setDialogState(() => semester = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        hintText: 'e.g., Data Structures',
                        prefixIcon: Icon(Icons.book_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: driveLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Google Drive Link',
                        hintText: 'https://drive.google.com/...',
                        prefixIcon: Icon(Icons.link_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: uploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: uploading
                      ? null
                      : () async {
                          if (year.isEmpty ||
                              branch.isEmpty ||
                              semester.isEmpty ||
                              subjectController.text.trim().isEmpty ||
                              driveLinkController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => uploading = true);

                          try {
                            await Api.uploadPyq(
                              uploaderRoll: UserSession.rollNumber,
                              year: year,
                              branch: branch,
                              semester: semester,
                              subject: subjectController.text.trim(),
                              driveLink: driveLinkController.text.trim(),
                            );

                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'PYQ uploaded successfully',
                                ),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                            await _loadPapers();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Upload failed: $e')),
                            );
                          } finally {
                            setDialogState(() => uploading = false);
                          }
                        },
                  icon: const Icon(Icons.upload_rounded),
                  label: uploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.richBrown,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    subjectController.dispose();
    driveLinkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            const Text('PYQ Library'),
          ],
        ),
        backgroundColor: AppTheme.richBrown,
        elevation: 8,
        actions: [
          if (UserSession.isAdmin)
            IconButton(
              tooltip: 'Upload PYQ',
              onPressed: _showUploadDialog,
              icon: const Icon(Icons.add_box_rounded),
            ),
        ],
      ),
      body: _isLoadingOptions
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.richBrown),
                  const SizedBox(height: 16),
                  Text(
                    'Loading PYQs...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: RefreshIndicator(
                color: AppTheme.richBrown,
                onRefresh: _loadPapers,
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 0,
                    end: 1,
                  ).animate(_fadeController),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Filters Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.golden.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filters',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedYear,
                                    decoration: const InputDecoration(
                                      labelText: 'Year',
                                      isDense: true,
                                      prefixIcon: Icon(
                                        Icons.calendar_month_rounded,
                                      ),
                                    ),
                                    items: _years
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _selectedYear = v);
                                        _loadPapers();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedBranch,
                                    decoration: const InputDecoration(
                                      labelText: 'Branch',
                                      isDense: true,
                                      prefixIcon: Icon(Icons.school_rounded),
                                    ),
                                    items: _branches
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _selectedBranch = v);
                                        _loadPapers();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedSemester,
                              decoration: const InputDecoration(
                                labelText: 'Semester',
                                prefixIcon: Icon(Icons.layers_rounded),
                              ),
                              items: _semesters
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedSemester = v);
                                  _loadPapers();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Papers List
                      if (_isLoadingPapers)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                              color: AppTheme.richBrown,
                            ),
                          ),
                        )
                      else if (_papers.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppTheme.cream,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.golden.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 48,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No PYQs found',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: _papers
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildPaperCard(entry.value),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPaperCard(Map<String, dynamic> paper) {
    final subject = paper['subject']?.toString() ?? 'Untitled';
    final driveLink = paper['drive_link']?.toString() ?? '';
    final uploadedBy = paper['uploaded_by']?.toString() ?? 'Unknown';

    return Card(
      elevation: 8,
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.golden.withOpacity(0.2)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.lightCream,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.description_rounded,
                color: AppTheme.cream,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: $uploadedBy',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.open_in_new_rounded, color: AppTheme.richBrown),
              onPressed: () => _openDriveLink(driveLink),
            ),
          ],
        ),
      ),
    );
  }
}
