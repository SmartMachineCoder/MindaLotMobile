import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/message.dart';
import '../../core/models/mood.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/counsellor_provider.dart';

class CounsellorChatScreen extends StatefulWidget {
  final String sessionId;
  const CounsellorChatScreen({super.key, required this.sessionId});

  @override
  State<CounsellorChatScreen> createState() =>
      _CounsellorChatScreenState();
}

class _CounsellorChatScreenState extends State<CounsellorChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  ChatSession? _session;

  @override
  void initState() {
    super.initState();
    ChatService().sessionStream(widget.sessionId).listen((s) {
      if (mounted) setState(() => _session = s);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await ChatService().sendMessage(
      sessionId: widget.sessionId,
      text: text,
      sender: MessageSender.counsellor,
    );
    _scrollToBottom();
  }

  Future<void> _endSession() async {
    await ChatService().endSession(widget.sessionId);
    if (mounted) Navigator.pop(context);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mood = _moodFromString(_session?.currentMood);
    final moodConfig = MoodData.get(mood);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(moodConfig),
      body: Column(
        children: [
          // Mood info banner
          _MoodBanner(config: moodConfig, session: _session),
          Expanded(child: _buildMessages()),
          _buildInput(moodConfig),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MoodConfig moodConfig) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF5C3D2E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            _session?.userAlias ?? 'User',
            style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810)),
          ),
          Text(
            '${moodConfig.emoji} Feeling ${moodConfig.label}',
            style: GoogleFonts.nunito(
                fontSize: 12, color: moodConfig.primaryColor),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _showEndDialog(),
          child: Text('End',
              style: GoogleFonts.nunito(
                  color: Colors.red.shade400, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<List<ChatMessage>>(
      stream: ChatService().messagesStream(widget.sessionId),
      builder: (context, snap) {
        final messages = snap.data ?? [];
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (_, i) => _CounsellorMessageBubble(
            msg: messages[i],
            onLongPress: messages[i].sender == MessageSender.counsellor &&
                    _session?.status == ChatSessionStatus.active
                ? () => _confirmDelete(messages[i])
                : null,
          ),
        );
      },
    );
  }

  Widget _buildInput(MoodConfig config) {
    final isActive = _session?.status == ChatSessionStatus.active;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: isActive,
              maxLines: null,
              decoration: InputDecoration(
                hintText: isActive ? 'Type a response...' : 'Session ended',
                hintStyle:
                    GoogleFonts.nunito(color: const Color(0xFFB0A090)),
                filled: true,
                fillColor: const Color(0xFFF5F0EB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
              ),
              style: GoogleFonts.nunito(fontSize: 15),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isActive ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF5C3D2E) : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ChatMessage msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Delete message?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
          '"${msg.text.length > 50 ? msg.text.substring(0, 50) + '...' : msg.text}"',
          style: GoogleFonts.nunito(
              fontSize: 14, fontStyle: FontStyle.italic),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF7A6055))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ChatService()
                  .deleteMessage(widget.sessionId, msg.id);
            },
            child: Text('Delete',
                style: GoogleFonts.nunito(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('End Session?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
          'This will end the chat session for the user.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style:
                    GoogleFonts.nunito(color: const Color(0xFF7A6055))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E)),
            child: Text('End Session',
                style: GoogleFonts.nunito(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MoodBanner extends StatelessWidget {
  final MoodConfig config;
  final ChatSession? session;
  const _MoodBanner({required this.config, required this.session});

  @override
  Widget build(BuildContext context) {
    if (config.type == MoodType.none) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: config.primaryColor.withOpacity(0.08),
      child: Row(
        children: [
          Text(config.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User is feeling ${config.label}',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: config.primaryColor),
                ),
                Text(
                  '${config.backgroundDescription} • ${config.musicDescription}',
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: const Color(0xFF7A6055)),
                ),
              ],
            ),
          ),
          if (session?.isUserPaid == true)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7DBF8E).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Paid',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: const Color(0xFF4A9B60),
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class _CounsellorMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final VoidCallback? onLongPress;
  const _CounsellorMessageBubble({required this.msg, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final isCounsellor = msg.sender == MessageSender.counsellor;
    final isSystem = msg.sender == MessageSender.system;

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4F4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            msg.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF7A6055),
                fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment:
            isCounsellor ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isCounsellor
                ? const Color(0xFF5C3D2E)
                : const Color(0xFFF0EBE5),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isCounsellor ? 18 : 4),
              bottomRight: Radius.circular(isCounsellor ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: isCounsellor
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isCounsellor)
                Text('User',
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7A6055))),
              Text(
                msg.text,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: isCounsellor
                      ? Colors.white
                      : const Color(0xFF2C1810),
                  height: 1.4,
                ),
              ),
              Text(
                _time(msg.timestamp),
                style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: isCounsellor
                        ? Colors.white54
                        : const Color(0xFF7A6055)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

MoodType _moodFromString(String? mood) {
  if (mood == null) return MoodType.none;
  return MoodType.values.firstWhere(
    (e) => e.name == mood,
    orElse: () => MoodType.none,
  );
}
