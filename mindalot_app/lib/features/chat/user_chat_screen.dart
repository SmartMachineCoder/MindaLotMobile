import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/models/message.dart';
import '../../core/models/mood.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/mood_provider.dart';
import '../../core/services/auth_service.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  ChatSession? _session;
  bool _isCreatingSession = false;

  // Freemium timer — 5 minutes free
  static const int freeDurationSeconds = 300;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _sessionCut = false;
  bool _isUserPaid = false;

  String? _userAlias;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userAlias = await AuthService().getUserAlias();
    _isUserPaid = await AuthService().isUserPaid();
    await _createSession();
  }

  Future<void> _createSession() async {
    if (_isCreatingSession) return;
    setState(() => _isCreatingSession = true);

    final mood = context.read<MoodProvider>().currentMood;
    final session = await ChatService().createSession(
      userAlias: _userAlias ?? 'Friend',
      mood: mood,
      isUserPaid: _isUserPaid,
    );

    setState(() {
      _session = session;
      _isCreatingSession = false;
    });

    // Listen for counsellor acceptance to start timer
    ChatService().sessionStream(session.id).listen((updated) {
      if (!mounted) return;
      if (updated == null) return;
      setState(() => _session = updated);

      if (updated.status == ChatSessionStatus.active && _timer == null) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);

      if (!_isUserPaid && _elapsedSeconds >= freeDurationSeconds) {
        _timer?.cancel();
        setState(() => _sessionCut = true);
        ChatService().endSession(_session!.id);
      }
    });
  }

  int get _remainingSeconds =>
      (freeDurationSeconds - _elapsedSeconds).clamp(0, freeDurationSeconds);

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _session == null || _sessionCut) return;

    _textController.clear();
    await ChatService().sendMessage(
      sessionId: _session!.id,
      text: text,
      sender: MessageSender.user,
    );
    _scrollToBottom();
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

  Future<void> _endChat() async {
    if (_session != null) {
      await ChatService().endSession(_session!.id);
    }
    _timer?.cancel();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, _) {
        final config = moodProvider.currentConfig;
        return Scaffold(
          backgroundColor: config.backgroundColor,
          appBar: _buildAppBar(config),
          body: _sessionCut
              ? _SessionCutScreen()
              : Column(
                  children: [
                    if (!_isUserPaid &&
                        _session?.status == ChatSessionStatus.active)
                      _FreeTimerBanner(
                          timerText: _timerText,
                          elapsed: _elapsedSeconds,
                          total: freeDurationSeconds,
                          color: config.primaryColor),
                    Expanded(child: _buildMessages()),
                    _buildInput(config),
                  ],
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(MoodConfig config) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF5C3D2E)),
        onPressed: () => _showEndChatDialog(),
      ),
      title: Column(
        children: [
          Text('Your Counsellor',
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C1810))),
          Text(
            _session?.status == ChatSessionStatus.waiting
                ? 'Connecting you...'
                : _session?.status == ChatSessionStatus.active
                    ? 'Online • ${config.emoji} ${config.label}'
                    : 'Session ended',
            style: GoogleFonts.nunito(
                fontSize: 12, color: const Color(0xFF7A6055)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _showEndChatDialog,
          child: Text('End',
              style: GoogleFonts.nunito(
                  color: Colors.red.shade400, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildMessages() {
    if (_session == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF5C3D2E)),
            const SizedBox(height: 16),
            Text('Connecting you to your counsellor...',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF7A6055), fontSize: 14)),
          ],
        ),
      );
    }

    return StreamBuilder<List<ChatMessage>>(
      stream: ChatService().messagesStream(_session!.id),
      builder: (context, snap) {
        final messages = snap.data ?? [];
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'Start by saying hello 👋',
              style: GoogleFonts.nunito(
                  color: const Color(0xFF7A6055), fontSize: 14),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (_, i) => _MessageBubble(msg: messages[i]),
        );
      },
    );
  }

  Widget _buildInput(MoodConfig config) {
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
              enabled: !_sessionCut,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.nunito(color: const Color(0xFFB0A090)),
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
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: config.primaryColor,
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

  void _showEndChatDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('End Chat?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure you want to end this session?',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF7A6055))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endChat();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E)),
            child:
                Text('End Chat', style: GoogleFonts.nunito(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FreeTimerBanner extends StatelessWidget {
  final String timerText;
  final int elapsed;
  final int total;
  final Color color;

  const _FreeTimerBanner({
    required this.timerText,
    required this.elapsed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = elapsed / total;
    final isWarning = progress > 0.75;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isWarning
          ? Colors.orange.shade50
          : color.withOpacity(0.08),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: isWarning ? Colors.orange : color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Free session: $timerText remaining',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isWarning ? Colors.orange.shade800 : color,
              ),
            ),
          ),
          LinearProgressIndicator(
            value: 1 - progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
                isWarning ? Colors.orange : color),
            minHeight: 4,
          ).let((w) => SizedBox(width: 60, child: w)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.sender == MessageSender.user;
    final isSystem = msg.sender == MessageSender.system;

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF5C3D2E) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: isUser ? Colors.white : const Color(0xFF2C1810),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _SessionCutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⏱️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(
            'Your free session has ended',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2C1810)),
          ),
          const SizedBox(height: 12),
          Text(
            'To continue speaking with your counsellor, please subscribe to a plan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 15, color: const Color(0xFF7A6055), height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Text('View Subscription Plans',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 32),
          _CrisisBox(),
        ],
      ),
    );
  }
}

class _CrisisBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need immediate support? 💛',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: const Color(0xFF5C3D2E)),
          ),
          const SizedBox(height: 8),
          _helpline('iCall', '9152987821', 'Mon–Sat, 8AM–10PM'),
          _helpline('Vandrevala Foundation', '1860-2662-345', '24/7'),
        ],
      ),
    );
  }

  Widget _helpline(String name, String number, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.phone_outlined,
              size: 16, color: Color(0xFF5C3D2E)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.nunito(
                    fontSize: 13, color: const Color(0xFF2C1810)),
                children: [
                  TextSpan(
                      text: '$name: ',
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: '$number ($hours)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
