import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../session.dart';
import '../theme/app_theme.dart';

class ClubChatPage extends StatefulWidget {
  final String clubName;

  const ClubChatPage({super.key, required this.clubName});

  @override
  State<ClubChatPage> createState() => _ClubChatPageState();
}

class _ClubChatPageState extends State<ClubChatPage> {
  final TextEditingController _controller = TextEditingController();

  bool _loading = true;
  bool _sending = false;
  bool _requesting = false;

  String _status = 'not_requested';
  bool _canSendMessage = false;
  bool _isAdmin = false;

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() {
      _loading = true;
    });

    try {
      final access = await Api.fetchClubAccess(
        clubName: widget.clubName,
        studentRoll: UserSession.rollNumber,
      );

      _status = (access['status'] ?? 'not_requested').toString();
      _canSendMessage = access['can_send_message'] == true;
      _isAdmin = access['is_admin'] == true || UserSession.isAdmin;

      if (_status == 'approved' || _isAdmin) {
        _messages = await Api.fetchClubMessages(
          clubName: widget.clubName,
          studentRoll: UserSession.rollNumber,
        );
      } else {
        _messages = [];
      }

      if (_isAdmin) {
        _pendingRequests = await Api.fetchClubRequests(
          clubName: widget.clubName,
          adminRoll: UserSession.rollNumber,
        );
        _members = await Api.fetchClubMembers(
          clubName: widget.clubName,
          adminRoll: UserSession.rollNumber,
        );
      } else {
        _pendingRequests = [];
        _members = [];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load club data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _requestEntry() async {
    if (_requesting) {
      return;
    }

    setState(() {
      _requesting = true;
    });

    try {
      await Api.requestClubAccess(
        clubName: widget.clubName,
        studentRoll: UserSession.rollNumber,
        studentName: UserSession.name,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted to admin.')),
        );
      }
      await _refreshAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _requesting = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_sending || _controller.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await Api.sendClubMessage(
        clubName: widget.clubName,
        studentRoll: UserSession.rollNumber,
        sender: UserSession.name,
        text: _controller.text.trim(),
      );
      _controller.clear();
      _messages = await Api.fetchClubMessages(
        clubName: widget.clubName,
        studentRoll: UserSession.rollNumber,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Message send failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Future<void> _decideRequest({
    required String requestId,
    required String action,
    required bool canSendMessage,
  }) async {
    try {
      await Api.decideClubRequest(
        clubName: widget.clubName,
        requestId: requestId,
        adminRoll: UserSession.rollNumber,
        action: action,
        canSendMessage: canSendMessage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request ${action}d successfully.')),
        );
      }
      await _refreshAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update request: $e')));
      }
    }
  }

  Future<void> _toggleMemberPermission(String roll, bool canSend) async {
    try {
      await Api.updateClubMemberMessagePermission(
        clubName: widget.clubName,
        studentRoll: roll,
        adminRoll: UserSession.rollNumber,
        canSendMessage: canSend,
      );
      await _refreshAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Permission update failed: $e')));
      }
    }
  }

  Widget _buildStatusCard() {
    if (_isAdmin) {
      return Card(
        color: const Color(0xFFEAF2FF),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'Admin mode: You can manage requests and message permissions.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (_status == 'approved') {
      return Card(
        color: const Color(0xFFEFFDF8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            _canSendMessage
                ? 'Access approved. You can view and send messages.'
                : 'Access approved. You can view messages, but sending is disabled by admin.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (_status == 'pending') {
      return Card(
        color: const Color(0xFFFFF5E8),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'Your access request is pending admin approval.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (_status == 'rejected') {
      return Card(
        color: const Color(0xFFFFEBEE),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'Your previous request was rejected. You may request again.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFFFFF5E8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'You need admin approval to enter this club chat.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _requesting ? null : _requestEntry,
              child: _requesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminRequests() {
    if (!_isAdmin || _pendingRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Requests',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._pendingRequests.map((request) {
              final requestId = (request['id'] ?? '').toString();
              final studentName = (request['student_name'] ?? '').toString();
              final studentRoll = (request['student_roll'] ?? '').toString();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      studentName.isEmpty ? studentRoll : studentName,
                    ),
                    subtitle: Text('Roll: $studentRoll'),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        TextButton(
                          onPressed: () => _decideRequest(
                            requestId: requestId,
                            action: 'approve',
                            canSendMessage: false,
                          ),
                          child: const Text('Approve (View)'),
                        ),
                        TextButton(
                          onPressed: () => _decideRequest(
                            requestId: requestId,
                            action: 'approve',
                            canSendMessage: true,
                          ),
                          child: const Text('Approve (Send)'),
                        ),
                        TextButton(
                          onPressed: () => _decideRequest(
                            requestId: requestId,
                            action: 'reject',
                            canSendMessage: false,
                          ),
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMembers() {
    if (!_isAdmin || _members.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approved Members',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._members.map((member) {
              final studentName = (member['student_name'] ?? '').toString();
              final studentRoll = (member['student_roll'] ?? '').toString();
              final canSend = member['can_send_message'] == true;

              return SwitchListTile(
                value: canSend,
                onChanged: (v) => _toggleMemberPermission(studentRoll, v),
                title: Text(studentName.isEmpty ? studentRoll : studentName),
                subtitle: Text('Roll: $studentRoll  •  Allow send message'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    if (!(_isAdmin || _status == 'approved')) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Chat will appear after your request is approved.'),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No messages yet. Start the conversation.'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _messages.length,
        itemBuilder: (context, i) {
          final m = _messages[i];
          final sender = (m['sender'] ?? '').toString();
          final text = (m['text'] ?? '').toString();
          final isMine = sender == UserSession.name;

          return Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppTheme.richBrown : const Color(0xFFF6F9FF),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isMine ? 14 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isMine ? Colors.white70 : AppTheme.richBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMine ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComposer() {
    final canCompose = _isAdmin || (_status == 'approved' && _canSendMessage);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.blueGrey.shade50)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: canCompose,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: canCompose
                    ? 'Type a message'
                    : 'Sending is disabled for your account',
                prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: canCompose ? AppTheme.richBrown : Colors.blueGrey.shade300,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: (!canCompose || _sending) ? null : _sendMessage,
              child: SizedBox(
                height: 52,
                width: 52,
                child: Center(
                  child: _sending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canViewChat = _isAdmin || _status == 'approved';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.group_rounded, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            Text(widget.clubName),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppTheme.richBrown,
        elevation: 8,
        actions: [
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.cream),
          ),
        ],
      ),
      backgroundColor: AppTheme.lightCream,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 8),
                        _buildAdminRequests(),
                        _buildAdminMembers(),
                        if (canViewChat) _buildMessages(),
                      ],
                    ),
                  ),
                  if (canViewChat) _buildComposer(),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
