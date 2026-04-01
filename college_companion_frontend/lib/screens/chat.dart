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

    return Scaffold(
      appBar: AppBar(title: Text(widget.group), centerTitle: false),
      body: Column(
        children: [
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
                        alignment:
                            isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMine ? AppTheme.brandBlue : Colors.white,
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
                                  color: isMine ? Colors.white70 : AppTheme.brandBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isMine ? Colors.white : AppTheme.textStrong,
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
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.blueGrey.shade50)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Type a message',
                        prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppTheme.brandBlue,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _sending ? null : _sendMessage,
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
