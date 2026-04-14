import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../session.dart';
import '../../theme/app_theme.dart';

class ElectionResultsScreen extends StatefulWidget {
  final Map<String, dynamic> election;
  final List<Map<String, dynamic>> candidates;

  const ElectionResultsScreen({
    super.key,
    required this.election,
    required this.candidates,
  });

  @override
  State<ElectionResultsScreen> createState() => _ElectionResultsScreenState();
}

class _ElectionResultsScreenState extends State<ElectionResultsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, int> _results = {};
  int _totalVotes = 0;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final results = await Api.fetchElectionResults(
        electionId: widget.election['id'],
        requestingRoll: UserSession.rollNumber,
      );
      
      int total = 0;
      for (var val in results.values) {
        total += val;
      }

      setState(() {
        _results = results;
        _totalVotes = total;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightCream,
        appBar: AppBar(title: const Text('Live Results'), backgroundColor: AppTheme.richBrown),
        body: Center(child: CircularProgressIndicator(color: AppTheme.richBrown)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppTheme.lightCream,
        appBar: AppBar(title: const Text('Results Unavailable'), backgroundColor: AppTheme.richBrown),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 64, color: AppTheme.textMuted),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    // Sort candidates by votes
    var sortedCandidates = List<Map<String, dynamic>>.from(widget.candidates);
    sortedCandidates.sort((a, b) {
      int votesA = _results[a['id']] ?? 0;
      int votesB = _results[b['id']] ?? 0;
      return votesB.compareTo(votesA); // Descending
    });

    Map<String, dynamic>? winner;
    if (_totalVotes > 0 && widget.election['status'] == 'ended' && sortedCandidates.isNotEmpty) {
      winner = sortedCandidates.first;
    }

    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(
        title: Text(widget.election['status'] == 'ended' ? 'Final Results' : 'Live Results'),
        backgroundColor: AppTheme.richBrown,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Winner Banner (if ended)
            if (winner != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    const Text('WINNER!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(winner['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.surface)),
                    Text('With ${(((_results[winner['id']] ?? 0) / _totalVotes) * 100).toStringAsFixed(1)}% of the votes', style: TextStyle(color: AppTheme.surface.withOpacity(0.85))),
                  ],
                ),
              ),

             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AppTheme.cream,
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Text('Total Votes Cast: $_totalVotes', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.richBrown)),
             ),
             const SizedBox(height: 24),

             if (_totalVotes == 0)
               const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No votes have been cast yet.')))
             else
               ...sortedCandidates.map((c) {
                 int votes = _results[c['id']] ?? 0;
                 double percentage = _totalVotes > 0 ? votes / _totalVotes : 0.0;
                 
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 24),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           if (c['photo_url'] != null && c['photo_url'].toString().isNotEmpty)
                             CircleAvatar(radius: 16, backgroundImage: NetworkImage(c['photo_url'])),
                           if (c['photo_url'] == null || c['photo_url'].toString().isEmpty)
                             CircleAvatar(radius: 16, backgroundColor: AppTheme.richBrown.withOpacity(0.2), child: Icon(Icons.person, size: 16, color: AppTheme.richBrown)),
                           
                           const SizedBox(width: 8),
                           Expanded(child: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                           Text('$votes votes (${(percentage * 100).toStringAsFixed(1)}%)', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                         ],
                       ),
                       const SizedBox(height: 8),
                       ClipRRect(
                         borderRadius: BorderRadius.circular(8),
                         child: LinearProgressIndicator(
                           value: percentage,
                           minHeight: 12,
                           backgroundColor: AppTheme.golden.withOpacity(0.2),
                           valueColor: AlwaysStoppedAnimation<Color>(AppTheme.richBrown),
                         ),
                       ),
                     ],
                   ),
                 );
               }),
          ],
        ),
      ),
    );
  }
}
