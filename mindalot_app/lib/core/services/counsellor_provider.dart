import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'chat_service.dart';
import '../models/message.dart';

class CounsellorProvider extends ChangeNotifier {
  CounsellorUser? _currentCounsellor;
  List<ChatSession> _activeSessions = [];
  List<ChatSession> _waitingSessions = [];
  bool _isLoading = false;

  static const int maxConcurrentChats = 2;

  CounsellorUser? get currentCounsellor => _currentCounsellor;
  List<ChatSession> get activeSessions => _activeSessions;
  List<ChatSession> get waitingSessions => _waitingSessions;
  bool get isLoggedIn => _currentCounsellor != null;
  bool get isLoading => _isLoading;
  bool get canAcceptMore => _activeSessions.length < maxConcurrentChats;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await AuthService().signInCounsellor(email, password);
    _isLoading = false;

    if (user != null) {
      _currentCounsellor = user;
      _startListening();
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void _startListening() {
    if (_currentCounsellor == null) return;

    // Listen to active sessions for this counsellor
    ChatService()
        .activeCounsellorSessions(_currentCounsellor!.uid)
        .listen((sessions) {
      _activeSessions = sessions;
      notifyListeners();
    });

    // Listen to waiting sessions (global)
    ChatService().waitingSessionsStream().listen((sessions) {
      _waitingSessions = sessions;
      notifyListeners();
    });
  }

  Future<void> acceptSession(String sessionId) async {
    if (!canAcceptMore || _currentCounsellor == null) return;
    await ChatService().acceptSession(
      sessionId: sessionId,
      counsellorId: _currentCounsellor!.uid,
      counsellorName: _currentCounsellor!.name,
    );
  }

  Future<void> logout() async {
    await AuthService().signOutCounsellor();
    _currentCounsellor = null;
    _activeSessions = [];
    _waitingSessions = [];
    notifyListeners();
  }
}
