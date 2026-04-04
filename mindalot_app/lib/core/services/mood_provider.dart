import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood.dart';
import 'audio_service.dart';

class MoodProvider extends ChangeNotifier {
  MoodType _currentMood = MoodType.none;
  DateTime? _moodLockedUntil;
  bool _isMuted = false;

  // Mood lock duration — 10 seconds for testing/POC demo
  static const Duration lockDuration = Duration(seconds: 10);

  MoodType get currentMood => _currentMood;
  MoodConfig get currentConfig => MoodData.get(_currentMood);
  bool get isMuted => _isMuted;

  bool get isMoodLocked {
    if (_moodLockedUntil == null) return false;
    return DateTime.now().isBefore(_moodLockedUntil!);
  }

  Duration get remainingLockTime {
    if (_moodLockedUntil == null) return Duration.zero;
    final remaining = _moodLockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  MoodProvider() {
    _loadPersistedMood();
  }

  Future<void> _loadPersistedMood() async {
    final prefs = await SharedPreferences.getInstance();
    final moodName = prefs.getString('currentMood');
    final lockUntilMs = prefs.getInt('moodLockedUntil');

    if (moodName != null && lockUntilMs != null) {
      final lockUntil =
          DateTime.fromMillisecondsSinceEpoch(lockUntilMs);
      if (DateTime.now().isBefore(lockUntil)) {
        _currentMood = MoodType.values.firstWhere(
          (e) => e.name == moodName,
          orElse: () => MoodType.none,
        );
        _moodLockedUntil = lockUntil;
        await AudioService().playMoodAudio(_currentMood);
        notifyListeners();
      }
    }
  }

  Future<void> selectMood(MoodType mood) async {
    if (isMoodLocked) return; // Cannot change while locked

    _currentMood = mood;
    _moodLockedUntil = DateTime.now().add(lockDuration);

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentMood', mood.name);
    await prefs.setInt(
        'moodLockedUntil', _moodLockedUntil!.millisecondsSinceEpoch);

    // Play audio
    await AudioService().playMoodAudio(mood);

    notifyListeners();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await AudioService().setMuted(_isMuted);
    notifyListeners();
  }

  String formatRemainingTime() {
    final d = remainingLockTime;
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
