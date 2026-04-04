import 'package:just_audio/just_audio.dart';
import '../models/mood.dart';

/// Pre-loads all 5 mood audio files at startup.
/// Switching moods just pauses one player and resumes another — instant.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final Map<MoodType, AudioPlayer> _players = {};
  MoodType _currentMood = MoodType.none;
  bool _isMuted = false;
  bool _isInitialized = false;

  bool get isMuted => _isMuted;
  MoodType get currentMood => _currentMood;

  /// Call once at app startup (e.g. in main.dart or home screen init).
  /// Pre-loads all mood audio so switching is zero-delay.
  Future<void> preloadAll() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final moods = [
      MoodType.happy,
      MoodType.sad,
      MoodType.anxious,
      MoodType.angry,
      MoodType.confused,
    ];

    // Load all in parallel
    await Future.wait(moods.map((mood) async {
      final config = MoodData.get(mood);
      if (config.audioAsset.isEmpty) return;

      try {
        final player = AudioPlayer();
        await player.setAsset(config.audioAsset);
        await player.setLoopMode(LoopMode.all);
        await player.setVolume(0.0);
        _players[mood] = player;
      } catch (e) {
        // Audio asset may not exist — silent fail
      }
    }));
  }

  Future<void> playMoodAudio(MoodType mood) async {
    if (mood == MoodType.none) {
      await stop();
      return;
    }
    if (mood == _currentMood) return;

    // Pause the old player
    if (_currentMood != MoodType.none && _players.containsKey(_currentMood)) {
      final oldPlayer = _players[_currentMood]!;
      await oldPlayer.pause();
      await oldPlayer.seek(Duration.zero);
    }

    _currentMood = mood;

    final player = _players[mood];
    if (player == null) return;

    // Start playing immediately, then fade in
    await player.setVolume(_isMuted ? 0.0 : 0.0);
    await player.seek(Duration.zero);
    await player.play();

    if (!_isMuted) {
      _fadeIn(player);
    }
  }

  /// Smooth 1.5s fade-in (non-blocking)
  void _fadeIn(AudioPlayer player) async {
    const int steps = 15;
    const double targetVolume = 0.6;
    const durationPerStep = Duration(milliseconds: 100);

    for (int i = 1; i <= steps; i++) {
      if (_isMuted || !player.playing) break;
      await Future.delayed(durationPerStep);
      if (_isMuted || !player.playing) break;
      await player.setVolume((targetVolume / steps) * i);
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    final player = _players[_currentMood];
    if (player != null) {
      await player.setVolume(_isMuted ? 0.0 : 0.6);
    }
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    final player = _players[_currentMood];
    if (player != null) {
      await player.setVolume(_isMuted ? 0.0 : 0.6);
    }
  }

  Future<void> stop() async {
    if (_currentMood != MoodType.none && _players.containsKey(_currentMood)) {
      await _players[_currentMood]!.pause();
      await _players[_currentMood]!.seek(Duration.zero);
    }
    _currentMood = MoodType.none;
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
