import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../session.dart';

class PyqPage extends StatefulWidget {
  const PyqPage({super.key});

  @override
  State<PyqPage> createState() => _PyqPageState();
}

class _PyqPageState extends State<PyqPage> {
  List<String> _years = [];
  List<String> _branches = [];
  List<String> _semesters = [];

  String? _selectedYear;
  String? _selectedBranch;
  String? _selectedSemester;

  bool _isLoadingOptions = true;
  bool _isLoadingPapers = false;
  List<Map<String, dynamic>> _papers = [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });

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
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load PYQ options: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOptions = false;
        });
      }
    }
  }

  Future<void> _loadPapers() async {
    if (_selectedYear == null ||
        _selectedBranch == null ||
        _selectedSemester == null) {
      return;
    }

    setState(() {
      _isLoadingPapers = true;
    });

    try {
      final papers = await Api.fetchPyqs(
        year: _selectedYear!,
        branch: _selectedBranch!,
        semester: _selectedSemester!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _papers = papers;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load papers: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPapers = false;
        });
      }
    }
  }

  Future<void> _openDriveLink(String link) async {
    final url = Uri.tryParse(link);
    if (url == null) {
      if (!mounted) {
        return;
      }
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
              title: const Text('Upload PYQ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: year.isNotEmpty ? year : null,
                      decoration: const InputDecoration(labelText: 'Year'),
                      items: _years
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            year = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: branch.isNotEmpty ? branch : null,
                      decoration: const InputDecoration(labelText: 'Branch'),
                      items: _branches
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            branch = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: semester.isNotEmpty ? semester : null,
                      decoration: const InputDecoration(labelText: 'Semester'),
                      items: _semesters
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            semester = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        hintText: 'e.g. Data Structures',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: driveLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Google Drive Link',
                        hintText: 'https://drive.google.com/...',
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
                ElevatedButton(
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
                                content: Text(
                                  'Please fill all fields and enter a drive link.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            uploading = true;
                          });

                          try {
                            await Api.uploadPyq(
                              uploaderRoll: UserSession.rollNumber,
                              year: year,
                              branch: branch,
                              semester: semester,
                              subject: subjectController.text.trim(),
                              driveLink: driveLinkController.text.trim(),
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PYQ link added successfully.'),
                              ),
                            );
                            await _loadPapers();
                          } catch (e) {
                            if (!mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Upload failed: $e')),
                            );
                          } finally {
                            setDialogState(() {
                              uploading = false;
                            });
                          }
                        },
                  child: uploading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Upload'),
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
      appBar: AppBar(
        title: const Text('PYQ Library'),
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPapers,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedYear,
                          decoration: const InputDecoration(labelText: 'Year'),
                          items: _years
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) {
                              return;
                            }
                            setState(() {
                              _selectedYear = v;
                            });
                            _loadPapers();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedBranch,
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                          ),
                          items: _branches
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) {
                              return;
                            }
                            setState(() {
                              _selectedBranch = v;
                            });
                            _loadPapers();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSemester,
                    decoration: const InputDecoration(labelText: 'Semester'),
                    items: _semesters
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) {
                        return;
                      }
                      setState(() {
                        _selectedSemester = v;
                      });
                      _loadPapers();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingPapers)
                    const Center(child: CircularProgressIndicator())
                  else if (_papers.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No PYQs found for selected filters.'),
                      ),
                    )
                  else
                    ..._papers.map(
                      (paper) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.link_rounded),
                          title: Text(
                            paper['subject']?.toString() ?? 'Untitled',
                          ),
                          subtitle: Text(
                            '${paper['drive_link']}\nUploaded by: ${paper['uploaded_by']}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Open link',
                            icon: const Icon(Icons.open_in_new_rounded),
                            onPressed: () => _openDriveLink(
                              paper['drive_link']?.toString() ?? '',
                            ),
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
