import 'package:flutter/material.dart';

enum MoodType { happy, sad, anxious, angry, confused, none }

class MoodConfig {
  final MoodType type;
  final String label;
  final String emoji;
  final String emojiAsset;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;
  final String lottieAsset;       // assets/animations/mood_xxx.json
  final String audioAsset;        // assets/audio/mood_xxx.mp3
  final String backgroundDescription;
  final String musicDescription;

  const MoodConfig({
    required this.type,
    required this.label,
    required this.emoji,
    required this.emojiAsset,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.lottieAsset,
    required this.audioAsset,
    required this.backgroundDescription,
    required this.musicDescription,
  });
}

class MoodData {
  static const Map<MoodType, MoodConfig> configs = {
    MoodType.happy: MoodConfig(
      type: MoodType.happy,
      label: 'Happy',
      emoji: '😊',
      emojiAsset: 'assets/images/emoji_happy.png',
      primaryColor: Color(0xFFF5C842),
      backgroundColor: Color(0xFFFFF8E1),
      accentColor: Color(0xFFE6A800),
      lottieAsset: 'assets/animations/mood_happy.json',
      audioAsset: 'assets/audio/mood_happy.mp3',
      backgroundDescription: 'Golden sunrise meadow',
      musicDescription: 'Birdsong & acoustic guitar',
    ),
    MoodType.sad: MoodConfig(
      type: MoodType.sad,
      label: 'Sad',
      emoji: '😢',
      emojiAsset: 'assets/images/emoji_sad.png',
      primaryColor: Color(0xFFD4845A),
      backgroundColor: Color(0xFFFFF0E6),
      accentColor: Color(0xFFB5603A),
      lottieAsset: 'assets/animations/mood_sad.json',
      audioAsset: 'assets/audio/mood_sad.mp3',
      backgroundDescription: 'Cozy rain & candlelight',
      musicDescription: 'Soft piano & gentle rain',
    ),
    MoodType.anxious: MoodConfig(
      type: MoodType.anxious,
      label: 'Anxious',
      emoji: '😰',
      emojiAsset: 'assets/images/emoji_anxious.png',
      primaryColor: Color(0xFF7DBF8E),
      backgroundColor: Color(0xFFEEF7F0),
      accentColor: Color(0xFF4A9B60),
      lottieAsset: 'assets/animations/mood_anxious.json',
      audioAsset: 'assets/audio/mood_anxious.mp3',
      backgroundDescription: 'Forest canopy & sunlight',
      musicDescription: 'Forest sounds & theta binaural beats',
    ),
    MoodType.angry: MoodConfig(
      type: MoodType.angry,
      label: 'Frustrated',
      emoji: '😠',
      emojiAsset: 'assets/images/emoji_angry.png',
      primaryColor: Color(0xFF2E6E8E),
      backgroundColor: Color(0xFFE3F2F9),
      accentColor: Color(0xFF1A4F6E),
      lottieAsset: 'assets/animations/mood_angry.json',
      audioAsset: 'assets/audio/mood_angry.mp3',
      backgroundDescription: 'Vast open ocean waves',
      musicDescription: 'Rhythmic ocean waves',
    ),
    MoodType.confused: MoodConfig(
      type: MoodType.confused,
      label: 'Confused',
      emoji: '😕',
      emojiAsset: 'assets/images/emoji_confused.png',
      primaryColor: Color(0xFF9B7FD4),
      backgroundColor: Color(0xFFF3EEFF),
      accentColor: Color(0xFF6A4DB8),
      lottieAsset: 'assets/animations/mood_confused.json',
      audioAsset: 'assets/audio/mood_confused.mp3',
      backgroundDescription: 'Starry cosmos',
      musicDescription: 'Soft orchestral — Bach & Mozart',
    ),
  };

  static const MoodConfig defaultConfig = MoodConfig(
    type: MoodType.none,
    label: 'None',
    emoji: '🙂',
    emojiAsset: 'assets/images/emoji_happy.png',
    primaryColor: Color(0xFF5C3D2E),
    backgroundColor: Color(0xFFE8F4F4),
    accentColor: Color(0xFF3D2010),
    lottieAsset: 'assets/animations/mood_default.json',
    audioAsset: '',
    backgroundDescription: '',
    musicDescription: '',
  );

  static MoodConfig get(MoodType type) => configs[type] ?? defaultConfig;
}
