import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../core/services/mood_provider.dart';

class MoodLockBanner extends StatefulWidget {
  final MoodProvider provider;
  const MoodLockBanner({super.key, required this.provider});

  @override
  State<MoodLockBanner> createState() => _MoodLockBannerState();
}

class _MoodLockBannerState extends State<MoodLockBanner> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.provider.currentConfig;
    if (!widget.provider.isMoodLocked) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // Semi-transparent backdrop so it's readable on any background
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.primaryColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(config.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${config.label} — ${config.backgroundDescription}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  config.musicDescription,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: config.primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.provider.formatRemainingTime(),
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
