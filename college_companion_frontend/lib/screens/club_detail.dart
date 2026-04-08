import 'package:flutter/material.dart';
import 'club_chat.dart';
import '../services/api_service.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class ClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final Set<String> _requestingClubs = <String>{};
  int _currentPhotoIndex = 0;

  Future<void> _openOrRequestClub() async {
    final clubName = widget.club['name'] as String;

    if (UserSession.isAdmin) {
      _navigateToClub();
      return;
    }

    try {
      final access = await Api.fetchClubAccess(
        clubName: clubName,
        studentRoll: UserSession.rollNumber,
      );

      final status = (access['status'] ?? 'not_requested').toString();
      if (status == 'approved') {
        _navigateToClub();
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

      await _requestClub();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open club: $e')));
      }
    }
  }

  Future<void> _requestClub() async {
    final clubName = widget.club['name'] as String;

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

  void _navigateToClub() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClubChatPage(clubName: widget.club['name']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final photos = club['photos'] as List<dynamic>;
    final activities = club['activities'] as List<dynamic>;

    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // App Bar with Hero Image
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: AppTheme.richBrown,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  club['name'],
                  style: TextStyle(
                    color: AppTheme.cream,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      itemCount: photos.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPhotoIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          photos[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppTheme.richBrown.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.richBrown.withOpacity(0.3),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 50,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Photo indicator
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPhotoIndex == index
                                  ? AppTheme.cream
                                  : AppTheme.cream.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Category badge
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cream.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    club['category'],
                    style: TextStyle(
                      color: AppTheme.richBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description Section
                    _buildSectionCard(
                      title: 'About the Club',
                      icon: Icons.info_outline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club['description'],
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppTheme.textDark,
                                  height: 1.6,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.richBrown.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: AppTheme.richBrown,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    club['purpose'],
                                    style: TextStyle(
                                      color: AppTheme.richBrown,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Activities Section
                    _buildSectionCard(
                      title: 'Activities & Events',
                      icon: Icons.event_note,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: activities.map<Widget>((activity) {
                          return Chip(
                            label: Text(activity),
                            backgroundColor: AppTheme
                                .accentGradient
                                .colors
                                .first
                                .withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: AppTheme.accentGradient.colors.first,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Coordinator Section
                    _buildSectionCard(
                      title: 'Club Coordinator',
                      icon: Icons.person,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppTheme.cream,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  club['coordinator'],
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      club['contact'],
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Implement call functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Calling ${club['contact']}'),
                                ),
                              );
                            },
                            icon: Icon(Icons.call, color: AppTheme.richBrown),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _requestingClubs.contains(club['name'])
                            ? null
                            : _openOrRequestClub,
                        icon: _requestingClubs.contains(club['name'])
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                UserSession.isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.group_add,
                              ),
                        label: Text(
                          UserSession.isAdmin ? 'Manage Club' : 'Join Club',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.richBrown,
                          foregroundColor: AppTheme.cream,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppTheme.shadowColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 6,
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.lightCream,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.cream, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
