import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/mood.dart';
import '../../../core/services/mood_provider.dart';

class MoodSelector extends StatelessWidget {
  final MoodProvider provider;
  const MoodSelector({super.key, required this.provider});

  static const _moods = [
    MoodType.happy,
    MoodType.sad,
    MoodType.anxious,
    MoodType.angry,
    MoodType.confused,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _moods.map((mood) {
        final config = MoodData.get(mood);
        final isSelected = provider.currentMood == mood;
        final isLocked = provider.isMoodLocked && !isSelected;

        return GestureDetector(
          onTap: () {
            if (provider.isMoodLocked) {
              if (!isSelected) {
                _showLockedDialog(context, provider);
              }
              return;
            }
            provider.selectMood(mood);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? config.primaryColor.withOpacity(0.2)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(color: config.primaryColor, width: 2.5)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: config.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Opacity(
              opacity: isLocked ? 0.4 : 1.0,
              child: Column(
                children: [
                  Text(config.emoji,
                      style: TextStyle(
                          fontSize: isSelected ? 40 : 32)),
                  const SizedBox(height: 4),
                  Text(
                    config.label,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? config.primaryColor
                          : const Color(0xFF7A6055),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLockedDialog(BuildContext context, MoodProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Mood Locked 🔒',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
          'Your current mood is locked for ${provider.formatRemainingTime()} more.\n\nThis helps us track your emotional journey accurately.',
          style: GoogleFonts.nunito(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF5C3D2E),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
