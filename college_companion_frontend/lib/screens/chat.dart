import 'package:flutter/material.dart';
import '../session.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final String group;
  const ChatPage({super.key, required this.group});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  bool _sending = false;

  Future<void> fetch() async {
    final result = await Api.fetchMessages(widget.group);
    setState(() {
      messages = result;
    });
  }

  Future<void> _sendMessage() async {
    if (_sending || controller.text.trim().isEmpty) {
      return;
    }

    setState(() => _sending = true);

    try {
      await Api.sendMessage(
        widget.group,
        UserSession.name,
        controller.text.trim(),
        isAdmin: UserSession.isAdmin,
        isCr: UserSession.isCr,
      );
      controller.clear();
      await fetch();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserSession.name;
    final bool isRestrictedGroup = widget.group.endsWith(' Announcements') || widget.group.endsWith(' Notes');
    final bool canSend = !isRestrictedGroup || UserSession.isAdmin || UserSession.isCr;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppTheme.appBarFlexibleSpace(),
        title: Row(
          children: [
            Icon(Icons.chat_rounded, color: AppTheme.cream, size: 28),
            const SizedBox(width: 12),
            Text(widget.group),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppTheme.shadowColor,
      ),
      backgroundColor: AppTheme.backgroundLavender,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            AppTheme.headerPullUpLayer(),
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Text('No messages yet. Start the conversation.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[i];
                        final sender = (m['sender'] ?? '').toString();
                        final text = (m['text'] ?? '').toString();
                        final isMine = sender == currentUser;

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? AppTheme.primaryDark
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(isMine ? 14 : 4),
                                bottomRight: Radius.circular(isMine ? 4 : 14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isMine
                                        ? Colors.white70
                                        : AppTheme.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isMine
                                        ? Colors.white
                                        : AppTheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.primaryAccent.withOpacity(0.25),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        enabled: canSend,
                        decoration: InputDecoration(
                          labelText: canSend ? 'Type a message' : 'Restricted Group',
                          hintText: canSend ? '' : 'Only CRs can post here',
                          prefixIcon: Icon(canSend ? Icons.chat_bubble_outline_rounded : Icons.lock),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (canSend)
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(26),
                          onTap: _sending ? null : _sendMessage,
                          child: Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [AppTheme.softShadow],
                            ),
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
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                    ),
                            ),
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
