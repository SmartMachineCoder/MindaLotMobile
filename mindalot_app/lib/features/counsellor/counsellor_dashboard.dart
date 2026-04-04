import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/message.dart';
import '../../core/models/mood.dart';
import '../../core/services/counsellor_provider.dart';
import 'counsellor_chat_screen.dart';

class CounsellorDashboard extends StatelessWidget {
  const CounsellorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CounsellorProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/counsellor-login');
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F0EB),
          appBar: _buildAppBar(context, provider),
          body: RefreshIndicator(
            onRefresh: () async {},
            color: const Color(0xFF5C3D2E),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WelcomeCard(provider: provider),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Incoming Requests',
                  count: provider.waitingSessions.length,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                if (provider.waitingSessions.isEmpty)
                  const _EmptyState(
                    icon: '☕',
                    message: 'No waiting users right now',
                  )
                else
                  ...provider.waitingSessions.map((session) =>
                      _WaitingSessionCard(
                        session: session,
                        provider: provider,
                        onAccept: provider.canAcceptMore
                            ? () async {
                                await provider.acceptSession(session.id);
                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CounsellorChatScreen(
                                        sessionId: session.id),
                                  ),
                                );
                              }
                            : null,
                      )),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Active Chats',
                  count: provider.activeSessions.length,
                  color: const Color(0xFF5C3D2E),
                  subtitle: '${provider.activeSessions.length}/2 slots used',
                ),
                const SizedBox(height: 10),
                if (provider.activeSessions.isEmpty)
                  const _EmptyState(
                    icon: '💬',
                    message: 'No active chats',
                  )
                else
                  ...provider.activeSessions.map((session) =>
                      _ActiveSessionCard(
                        session: session,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CounsellorChatScreen(sessionId: session.id),
                          ),
                        ),
                      )),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CounsellorProvider provider) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Counsellor Panel',
        style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C1810)),
      ),
      actions: [
        // Capacity indicator
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: provider.canAcceptMore
                ? const Color(0xFF7DBF8E).withOpacity(0.15)
                : Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: provider.canAcceptMore
                  ? const Color(0xFF7DBF8E)
                  : Colors.red.shade300,
            ),
          ),
          child: Text(
            '${provider.activeSessions.length}/2',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: provider.canAcceptMore
                  ? const Color(0xFF4A9B60)
                  : Colors.red.shade700,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFF7A6055)),
          onPressed: () async {
            await provider.logout();
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, '/welcome');
          },
          tooltip: 'Sign out',
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final CounsellorProvider provider;
  const _WelcomeCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final h = DateTime.now().hour;
    final greeting =
        h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5C3D2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: GoogleFonts.nunito(
                      color: Colors.white70, fontSize: 13),
                ),
                Text(
                  provider.currentCounsellor?.name ?? 'Counsellor',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7DBF8E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('● Online',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C1810),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        if (subtitle != null) ...[
          const Spacer(),
          Text(subtitle!,
              style: GoogleFonts.nunito(
                  fontSize: 12, color: const Color(0xFF7A6055))),
        ],
      ],
    );
  }
}

class _WaitingSessionCard extends StatelessWidget {
  final ChatSession session;
  final CounsellorProvider provider;
  final VoidCallback? onAccept;

  const _WaitingSessionCard({
    required this.session,
    required this.provider,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final mood = _moodFromString(session.currentMood);
    final moodConfig = MoodData.get(mood);
    final waitTime = DateTime.now().difference(session.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Mood indicator
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: moodConfig.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(moodConfig.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.userAlias,
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF2C1810)),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Feeling ${moodConfig.label}',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: moodConfig.primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${_formatWait(waitTime)} ago',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: const Color(0xFF7A6055)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: onAccept != null
                  ? const Color(0xFF5C3D2E)
                  : Colors.grey.shade300,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              onAccept != null ? 'Accept' : 'Full',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: onAccept != null ? Colors.white : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatWait(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    return '${d.inMinutes}m';
  }
}

class _ActiveSessionCard extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;

  const _ActiveSessionCard(
      {required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mood = _moodFromString(session.currentMood);
    final moodConfig = MoodData.get(mood);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5C3D2E).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: moodConfig.primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(moodConfig.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.userAlias,
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF2C1810))),
                  Text(
                    'Feeling ${moodConfig.label} • Active',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: moodConfig.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Color(0xFF7A6055)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(message,
                style: GoogleFonts.nunito(
                    color: const Color(0xFF7A6055), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

MoodType _moodFromString(String? mood) {
  if (mood == null) return MoodType.none;
  return MoodType.values.firstWhere(
    (e) => e.name == mood,
    orElse: () => MoodType.none,
  );
}
