import 'package:flutter/material.dart';
import 'chat.dart';
import 'auth_choice.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = UserSession.groups;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi ${UserSession.name}'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) {
              if (value == 'logout') {
                UserSession.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthChoice()),
                  (_) => false,
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEAF2FF),
                child: Icon(
                  Icons.school_rounded,
                  size: 18,
                  color: AppTheme.brandBlue,
                ),
              ),
            ),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppTheme.brandBlue, AppTheme.brandSky],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Groups',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Join discussions and stay updated with your community.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.brandBlue,
                  ),
                ),
                title: const Text(
                  'PYQ Library',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Browse year-wise, branch-wise and semester-wise papers',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => Navigator.pushNamed(context, '/pyq'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppTheme.brandBlue,
                  ),
                ),
                title: const Text(
                  'Clubs',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Explore all college clubs'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => Navigator.pushNamed(context, '/clubs'),
              ),
            ),
            const SizedBox(height: 8),
            if (groups.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'No groups available yet.',
                    style: TextStyle(color: Colors.blueGrey.shade700),
                  ),
                ),
              ),
            ...groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppTheme.brandBlue,
                      ),
                    ),
                    title: Text(
                      group,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Tap to open group chat'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatPage(group: group)),
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
