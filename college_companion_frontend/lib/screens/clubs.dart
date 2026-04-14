import 'package:flutter/material.dart';
import 'club_detail.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final Set<String> _requestingClubs = <String>{};
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> clubs = [
    {
      'name': 'Altius Sports Club',
      'icon': Icons.sports_cricket_rounded,
      'category': 'Sports',
      'description':
          'Promoting physical fitness and sportsmanship among students through various athletic activities and competitions.',
      'purpose':
          'To encourage healthy lifestyle and competitive spirit through sports and games.',
      'activities': [
        'Cricket Tournaments',
        'Football Matches',
        'Athletics Events',
        'Sports Workshops',
      ],
      'coordinator': 'Dr. Rajesh Kumar',
      'contact': '+91-9876543210',
      'cover_image':
          'https://images.unsplash.com/photo-1521412644187-c49fa049e84d?w=400',
      'photos': [
        'https://images.unsplash.com/photo-1521412644187-c49fa049e84d?w=400',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400',
        'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400',
      ],
    },
    {
      'name': 'Clairvoyance Photography Club',
      'icon': Icons.camera_alt_rounded,
      'category': 'Photography',
      'description':
          'Capturing moments and fostering creativity through the art of photography and visual storytelling.',
      'purpose':
          'To develop photography skills and showcase artistic talents through various events and exhibitions.',
      'activities': [
        'Photography Workshops',
        'Photo Walks',
        'Exhibitions',
        'Contest Competitions',
      ],
      'coordinator': 'Prof. Priya Sharma',
      'contact': '+91-9876543211',
      'cover_image':
          'https://iso.500px.com/wp-content/uploads/2016/03/pedroquintela-1500x844.jpg',
      'photos': [
        'https://images.unsplash.com/photo-1516801716301-44ab060bd3d9?w=400',
        'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400',
        'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=400',
        'https://images.unsplash.com/photo-1554048612-b6a482dbe3c5?w=400',
      ],
    },
    {
      'name': 'Think India Club',
      'icon': Icons.public_rounded,
      'category': 'Literary',
      'description':
          'Promoting national consciousness and social awareness through discussions, debates, and community service.',
      'purpose':
          'To instill patriotic values and encourage social responsibility among students.',
      'activities': [
        'Debates',
        'Seminars',
        'Community Service',
        'National Day Celebrations',
      ],
      'coordinator': 'Dr. Amit Singh',
      'contact': '+91-9876543212',
      'cover_image':
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?w=400',
      'photos': [
        'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?w=400',
        'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
        'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400',
      ],
    },
    {
      'name': 'Technical Club',
      'icon': Icons.memory_rounded,
      'category': 'Technical',
      'description':
          'Advancing technical knowledge and innovation through workshops, projects, and hackathons.',
      'purpose':
          'To provide platform for students to explore cutting-edge technologies and develop practical skills.',
      'activities': [
        'Coding Workshops',
        'Hackathons',
        'Tech Talks',
        'Project Development',
      ],
      'coordinator': 'Prof. Sanjay Gupta',
      'contact': '+91-9876543213',
      'cover_image':
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
      'photos': [
        'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
        'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400',
        'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=400',
        'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400',
      ],
    },
    {
      'name': 'Literature Club',
      'icon': Icons.menu_book_rounded,
      'category': 'Literary',
      'description':
          'Celebrating the power of words through reading, writing, and literary discussions.',
      'purpose':
          'To cultivate literary appreciation and creative writing skills among students.',
      'activities': [
        'Book Clubs',
        'Writing Workshops',
        'Poetry Sessions',
        'Literary Festivals',
      ],
      'coordinator': 'Dr. Meera Patel',
      'contact': '+91-9876543214',
      'cover_image':
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
      'photos': [
        'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
      ],
    },
    {
      'name': 'Yoga Club',
      'icon': Icons.self_improvement_rounded,
      'category': 'Sports',
      'description':
          'Promoting mental and physical well-being through yoga practices and mindfulness activities.',
      'purpose':
          'To help students achieve balance between mind, body, and spirit through yoga and meditation.',
      'activities': [
        'Yoga Sessions',
        'Meditation Classes',
        'Wellness Workshops',
        'Stress Management Programs',
      ],
      'coordinator': 'Prof. Anjali Desai',
      'contact': '+91-9876543215',
      'cover_image':
          'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=400',
      'photos': [
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
      ],
    },
    {
      'name': 'BIS Club',
      'icon': Icons.verified_rounded,
      'category': 'Technical',
      'description':
          'Focusing on business intelligence and data analytics to prepare students for industry demands.',
      'purpose':
          'To bridge the gap between academic learning and industry requirements in data and analytics.',
      'activities': [
        'Data Analytics Workshops',
        'Industry Seminars',
        'Case Studies',
        'Certification Programs',
      ],
      'coordinator': 'Dr. Vikram Rao',
      'contact': '+91-9876543216',
      'cover_image':
          'https://images.unsplash.com/photo-1517256064527-09c73fc73e67?w=400',
      'photos': [
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
        'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=400',
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
      ],
    },
  ];

  List<String> get categories => [
    'All',
    ...clubs.map((club) => club['category'] as String).toSet(),
  ];

  List<Map<String, dynamic>> get filteredClubs {
    if (_selectedCategory == 'All') return clubs;
    return clubs
        .where((club) => club['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLavender,
      appBar: AppBar(
        flexibleSpace: AppTheme.appBarFlexibleSpace(),
        title: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            const Text('Clubs & Societies'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppTheme.shadowColor,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            AppTheme.headerPullUpLayer(),
            // Category Filter
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppTheme.primaryGradient
                              : null,
                          color: isSelected
                              ? null
                              : const Color(0xFFF3F0FF),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.transparent,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF7C3AED),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide.none,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Clubs Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.8, // Taller cards to prevent overflow and look modern
                ),
                itemCount: filteredClubs.length,
                itemBuilder: (context, index) {
                  final club = filteredClubs[index];
                  final clubName = club['name'] as String;
                  final isRequesting = _requestingClubs.contains(clubName);

                  return Card(
                    elevation: 6,
                    shadowColor: AppTheme.shadowColor,
                    clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: AppTheme.golden.withAlpha(51)),
                    ),
                    child: InkWell(
                      onTap: () => _navigateToClubDetail(club),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightCream,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top part: Image and Badges
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Cover Image
                                  club['cover_image'].toString().startsWith('assets/')
                                      ? Image.asset(
                                          club['cover_image'] as String,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: AppTheme.richBrown.withAlpha(20),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 28,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Image.network(
                                          club['cover_image'] as String,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: AppTheme.richBrown.withAlpha(20),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 28,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  // Gradient Overlay for better contrast
                                  Positioned(
                                    bottom: 0, left: 0, right: 0,
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.4),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Category Badge Overlay
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightCream.withAlpha(230),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        club['category'] as String,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.richBrown,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Icon overlay
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: index.isEven
                                            ? AppTheme.iconGradientA
                                            : AppTheme.iconGradientB,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [AppTheme.softShadow],
                                      ),
                                      child: Icon(
                                        club['icon'] as IconData,
                                        color: AppTheme.cream,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom part: Details taking intrinsic height
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Club Name
                                  Text(
                                    clubName,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textDark,
                                          height: 1.2,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Coordinator
                                  Text(
                                    'Coord: ${club['coordinator']}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  // Action Area
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (isRequesting)
                                        SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.richBrown,
                                          ),
                                        )
                                      else
                                        Text(
                                          UserSession.isAdmin
                                              ? 'Tap for details'
                                              : 'Tap to join',
                                          style: Theme.of(context).textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppTheme.richBrown,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (!isRequesting)
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.richBrown.withAlpha(20),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 14,
                                            color: AppTheme.richBrown,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToClubDetail(Map<String, dynamic> club) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
    );
  }
}
