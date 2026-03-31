import 'package:flutter/material.dart';
import 'club_chat.dart';
import '../services/api_service.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final Set<String> _requestingClubs = <String>{};

  Future<void> _openOrRequestClub(String clubName) async {
    if (UserSession.isAdmin) {
      _navigateToClub(clubName);
      return;
    }

    try {
      final access = await Api.fetchClubAccess(
        clubName: clubName,
        studentRoll: UserSession.rollNumber,
      );

      final status = (access['status'] ?? 'not_requested').toString();
      if (status == 'approved') {
        _navigateToClub(clubName);
        return;
      }

      if (status == 'pending') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your request is pending admin approval.'),
            ),
          );
        }
        return;
      }

      await _requestClub(clubName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open club: $e')));
      }
    }
  }

  Future<void> _requestClub(String clubName) async {
    if (_requestingClubs.contains(clubName)) {
      return;
    }

    setState(() {
      _requestingClubs.add(clubName);
    });

    try {
      await Api.requestClubAccess(
        clubName: clubName,
        studentRoll: UserSession.rollNumber,
        studentName: UserSession.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request sent for $clubName.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _requestingClubs.remove(clubName);
        });
      }
    }
  }

  void _navigateToClub(String clubName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClubChatPage(clubName: clubName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubs = [
      {'name': 'Altius Sports Club', 'icon': Icons.sports_cricket_rounded},
      {
        'name': 'Clairvoyance Photography Club',
        'icon': Icons.camera_alt_rounded,
      },
      {'name': 'Think India Club', 'icon': Icons.public_rounded},
      {'name': 'Technical Club', 'icon': Icons.memory_rounded},
      {'name': 'Literature Club', 'icon': Icons.menu_book_rounded},
      {'name': 'Yoga Club', 'icon': Icons.self_improvement_rounded},
      {'name': 'BIS Club', 'icon': Icons.verified_rounded},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Clubs & Societies')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          final club = clubs[index];
          final clubName = club['name'] as String;
          final isRequesting = _requestingClubs.contains(clubName);

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: isRequesting ? null : () => _openOrRequestClub(clubName),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      index.isEven
                          ? const Color(0xFFEAF2FF)
                          : const Color(0xFFEFFDF8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.brandBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        club['icon'] as IconData,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      clubName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isRequesting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        UserSession.isAdmin
                            ? 'Tap to open and manage chat'
                            : 'Tap to request/open (approval required)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
