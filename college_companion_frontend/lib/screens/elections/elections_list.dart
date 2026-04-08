import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../session.dart';
import '../../theme/app_theme.dart';
import 'admin_create_election.dart';
import 'election_detail.dart';
import 'package:intl/intl.dart';

class ElectionsListScreen extends StatefulWidget {
  const ElectionsListScreen({super.key});

  @override
  State<ElectionsListScreen> createState() => _ElectionsListScreenState();
}

class _ElectionsListScreenState extends State<ElectionsListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _elections = [];

  @override
  void initState() {
    super.initState();
    _loadElections();
  }

  Future<void> _loadElections() async {
    setState(() => _isLoading = true);
    try {
      final elections = await Api.fetchEligibleElections(studentRoll: UserSession.rollNumber);
      setState(() {
        _elections = elections;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load elections: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.how_to_vote_rounded, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            const Text('CR Elections'),
          ],
        ),
        backgroundColor: AppTheme.richBrown,
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: AppTheme.richBrown))
            : _elections.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 64, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text('No active elections found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textMuted)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.richBrown,
                  onRefresh: _loadElections,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _elections.length,
                    itemBuilder: (context, index) {
                      return _buildElectionCard(_elections[index]);
                    },
                  ),
                ),
      ),
      floatingActionButton: UserSession.isAdmin 
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCreateElectionScreen()),
                );
                if (result == true) {
                  _loadElections();
                }
              },
              backgroundColor: AppTheme.richBrown,
              icon: Icon(Icons.add, color: AppTheme.cream),
              label: Text('New Election', style: TextStyle(color: AppTheme.cream)),
            )
          : null,
    );
  }

  Widget _buildElectionCard(Map<String, dynamic> election) {
    final status = election['status'];
    final title = election['title'];
    final description = election['description'];
    final endDateStr = election['end_date'];
    
    DateTime? endDate;
    if (endDateStr != null && endDateStr.isNotEmpty) {
      endDate = DateTime.tryParse(endDateStr);
    }

    bool isEnded = status == 'ended' || (endDate != null && DateTime.now().isAfter(endDate));

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.golden.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ElectionDetailScreen(election: election)),
          );
          if (result == true) _loadElections();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.lightCream,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge & Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEnded ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isEnded ? Colors.red : Colors.green),
                    ),
                    child: Text(
                      isEnded ? 'ENDED' : 'LIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isEnded ? Colors.red : Colors.green.shade700,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.textMuted),
              ),
              
              const SizedBox(height: 16),
              
              // Bottom row date
              Row(
                children: [
                  Icon(Icons.event_busy_rounded, size: 16, color: AppTheme.richBrown),
                  const SizedBox(width: 6),
                  Text(
                    endDate != null ? 'Ends: ${DateFormat('MMM dd, yyyy h:mm a').format(endDate)}' : 'No end date',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.richBrown),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
