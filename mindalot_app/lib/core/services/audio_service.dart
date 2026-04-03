import 'package:just_audio/just_audio.dart';
import '../models/mood.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  MoodType _currentMood = MoodType.none;
  bool _isMuted = false;

  bool get isMuted => _isMuted;
  MoodType get currentMood => _currentMood;

  Future<void> playMoodAudio(MoodType mood) async {
    if (mood == MoodType.none) {
      await stop();
      return;
    }
    if (mood == _currentMood && _player.playing) return;

    _currentMood = mood;
    final config = MoodData.get(mood);
    if (config.audioAsset.isEmpty) return;

    try {
      await _player.stop();
      await _player.setAsset(config.audioAsset);
      await _player.setLoopMode(LoopMode.all);
      await _player.setVolume(_isMuted ? 0.0 : 0.6);
      await _player.play();
    } catch (e) {
      // Audio asset may not exist in POC — silent fail
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _player.setVolume(_isMuted ? 0.0 : 0.6);
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await _player.setVolume(_isMuted ? 0.0 : 0.6);
  }

  Future<void> stop() async {
    _currentMood = MoodType.none;
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
