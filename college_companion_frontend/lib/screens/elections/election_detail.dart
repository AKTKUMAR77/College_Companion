import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../session.dart';
import '../../theme/app_theme.dart';
import 'election_results.dart';
import 'package:intl/intl.dart';

class ElectionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> election;
  const ElectionDetailScreen({super.key, required this.election});

  @override
  State<ElectionDetailScreen> createState() => _ElectionDetailScreenState();
}

class _ElectionDetailScreenState extends State<ElectionDetailScreen> {
  bool _isLoading = true;
  bool _isActionRunning = false;
  List<Map<String, dynamic>> _candidates = [];
  bool _hasVoted = false;
  late DateTime? _endDate;
  late String _status;
  late bool _isResultsLocked;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _status = widget.election['status'];
    _isResultsLocked = widget.election['is_results_locked'];
    final endStr = widget.election['end_date'];
    _endDate = (endStr != null && endStr.isNotEmpty) ? DateTime.tryParse(endStr) : null;
    
    _startTimer();
    _loadData();
  }

  void _startTimer() {
    if (_endDate != null && _status != 'ended') {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        if (now.isAfter(_endDate!)) {
          timer.cancel();
          if (mounted) setState(() { _status = 'ended'; }); // Auto close logically
        } else {
          if (mounted) setState(() {
            _timeLeft = _endDate!.difference(now);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final electionId = widget.election['id'];
      
      final candidates = await Api.fetchCandidates(electionId);
      
      bool hasVoted = false;
      if (!UserSession.isAdmin) {
        hasVoted = await Api.hasStudentVoted(electionId: electionId, studentRoll: UserSession.rollNumber);
      }

      setState(() {
        _candidates = candidates;
        _hasVoted = hasVoted;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _castVote(String candidateId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirm Vote'),
        content: const Text('Are you sure you want to cast your vote for this candidate? You cannot change it later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.richBrown),
            onPressed: () => Navigator.pop(c, true),
            child: Text('Confirm Vote', style: TextStyle(color: AppTheme.cream)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionRunning = true);
    try {
      await Api.castVote(
        electionId: widget.election['id'],
        candidateId: candidateId,
        studentRoll: UserSession.rollNumber,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Vote successfully cast!'), backgroundColor: Colors.green.shade700));
        setState(() => _hasVoted = true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isActionRunning = false);
    }
  }

  Future<void> _addCandidateForm() async {
    final nameC = TextEditingController();
    final rollC = TextEditingController();
    final photoC = TextEditingController();
    final manC = TextEditingController();

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Candidate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: rollC, decoration: const InputDecoration(labelText: 'Roll Number')),
              TextField(controller: photoC, decoration: const InputDecoration(labelText: 'Photo URL (Optional)')),
              TextField(controller: manC, maxLines: 3, decoration: const InputDecoration(labelText: 'Manifesto')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              setState(() => _isActionRunning = true);
              try {
                await Api.addCandidate(
                  adminRoll: UserSession.rollNumber,
                  electionId: widget.election['id'],
                  name: nameC.text,
                  rollNumber: rollC.text,
                  photoUrl: photoC.text,
                  manifesto: manC.text,
                );
                _loadData();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              } finally {
                if (mounted) setState(() => _isActionRunning = false);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "00h 00m 00s";
    return "${d.inHours.toString().padLeft(2, '0')}h ${(d.inMinutes % 60).toString().padLeft(2, '0')}m ${(d.inSeconds % 60).toString().padLeft(2, '0')}s";
  }

  @override
  Widget build(BuildContext context) {
    bool isLive = _status != 'ended' && (_endDate == null || DateTime.now().isBefore(_endDate!));
    bool canViewResults = UserSession.isAdmin || (!_isResultsLocked && !isLive);

    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        title: Text(widget.election['title']),
        backgroundColor: AppTheme.richBrown,
        actions: [
          if (canViewResults)
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ElectionResultsScreen(election: widget.election, candidates: _candidates)));
              },
            )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: AppTheme.richBrown))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Status Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isLive ? Colors.green.shade200 : Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(isLive ? 'ELECTION LIVE' : 'ELECTION ENDED', style: TextStyle(fontWeight: FontWeight.bold, color: isLive ? Colors.green.shade800 : Colors.red.shade800, fontSize: 18)),
                        if (isLive && _endDate != null) ...[
                          const SizedBox(height: 8),
                          Text('Time Remaining:', style: TextStyle(color: Colors.green.shade700)),
                          Text(_formatDuration(_timeLeft), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800, fontFeatures: const [FontFeature.tabularFigures()])),
                        ],
                      ],
                    ),
                  ),

                  // User Status Banner
                  if (!UserSession.isAdmin && isLive) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _hasVoted ? AppTheme.richBrown.withOpacity(0.1) : AppTheme.golden.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(_hasVoted ? Icons.check_circle : Icons.how_to_vote, color: AppTheme.richBrown),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _hasVoted ? "You have already cast your vote." : "Please select a candidate below to vote.",
                              style: TextStyle(color: AppTheme.richBrown, fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                  
                  const SizedBox(height: 24),
                  Text('Candidates', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (_candidates.isEmpty)
                    const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No candidates added yet.')))
                  else
                    ..._candidates.map(_buildCandidateCard),

                  const SizedBox(height: 24),
                  if (widget.election['rules'] != null && widget.election['rules'].toString().isNotEmpty) ...[
                     Text('Rules', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(color: AppTheme.cream, borderRadius: BorderRadius.circular(12)),
                       child: Text(widget.election['rules']),
                     ),
                     const SizedBox(height: 40),
                  ],
                  
                  // Admin Controls
                  if (UserSession.isAdmin) ...[
                     const Divider(),
                     Text('Admin Controls', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                     const SizedBox(height: 12),
                     Wrap(
                       spacing: 8,
                       runSpacing: 8,
                       children: [
                         ElevatedButton.icon(
                           onPressed: isLive ? _addCandidateForm : null,
                           icon: const Icon(Icons.person_add),
                           label: const Text('Add Candidate'),
                         ),
                         if (isLive)
                           ElevatedButton.icon(
                             onPressed: () async {
                               await Api.endElection(adminRoll: UserSession.rollNumber, electionId: widget.election['id']);
                               setState(() { _status = 'ended'; });
                             },
                             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                             icon: Icon(Icons.stop_circle, color: AppTheme.cream),
                             label: Text('End Now', style: TextStyle(color: AppTheme.cream)),
                           ),
                         ElevatedButton.icon(
                           onPressed: () async {
                             await Api.toggleResultsLock(adminRoll: UserSession.rollNumber, electionId: widget.election['id'], lock: !_isResultsLocked);
                             setState(() { _isResultsLocked = !_isResultsLocked; });
                           },
                           icon: Icon(_isResultsLocked ? Icons.lock_open : Icons.lock),
                           label: Text(_isResultsLocked ? 'Unlock Results' : 'Lock Results'),
                         ),
                       ],
                     ),
                     const SizedBox(height: 40),
                  ]
                ],
              ),
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    bool isLive = _status != 'ended' && (_endDate == null || DateTime.now().isBefore(_endDate!));
    bool canVote = !UserSession.isAdmin && isLive && !_hasVoted;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.golden.withOpacity(0.3),
                  backgroundImage: candidate['photo_url'] != null && candidate['photo_url'].toString().isNotEmpty 
                    ? NetworkImage(candidate['photo_url']) 
                    : null,
                  child: candidate['photo_url'] == null || candidate['photo_url'].toString().isEmpty 
                    ? Icon(Icons.person, size: 30, color: AppTheme.richBrown) 
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(candidate['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Roll: ${candidate['roll_number']}', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(candidate['manifesto'], style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            if (canVote) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isActionRunning ? null : () => _castVote(candidate['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.richBrown,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isActionRunning 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('VOTE FOR ${candidate['name'].toString().split(' ').first.toUpperCase()}', style: TextStyle(color: AppTheme.cream, fontWeight: FontWeight.bold)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
