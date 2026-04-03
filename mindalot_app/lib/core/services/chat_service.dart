import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/mood.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final _uuid = const Uuid();

  // Firebase is optional — falls back to in-memory mock for POC demo
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // ── In-memory POC store ──────────────────────────────────────────────────
  final Map<String, ChatSession> _mockSessions = {};
  final Map<String, List<ChatMessage>> _mockMessages = {};
  final Map<String, StreamController<ChatSession?>> _sessionControllers = {};
  final StreamController<List<ChatSession>> _waitingController =
      StreamController<List<ChatSession>>.broadcast();
  final Map<String, StreamController<List<ChatSession>>>
      _activeControllers = {};
  final Map<String, StreamController<List<ChatMessage>>>
      _messageControllers = {};

  void _broadcastWaiting() {
    final waiting = _mockSessions.values
        .where((s) => s.status == ChatSessionStatus.waiting)
        .toList();
    _waitingController.add(waiting);
  }

  void _broadcastSession(String sessionId) {
    _sessionControllers[sessionId]?.add(_mockSessions[sessionId]);
  }

  void _broadcastMessages(String sessionId) {
    final msgs = (_mockMessages[sessionId] ?? [])
        .where((m) => !m.isDeleted)
        .toList();
    _messageControllers[sessionId]?.add(msgs);
  }

  // ── Session Management ──────────────────────────────────────────────────

  Future<ChatSession> createSession({
    required String userAlias,
    required MoodType mood,
    bool isUserPaid = false,
  }) async {
    final id = _uuid.v4();
    final session = ChatSession(
      id: id,
      userAlias: userAlias,
      status: ChatSessionStatus.waiting,
      createdAt: DateTime.now(),
      currentMood: mood.name,
      isUserPaid: isUserPaid,
    );

    final db = _db;
    if (db != null) {
      await db.collection('sessions').doc(id).set(session.toMap());
      await sendMessage(
        sessionId: id,
        text:
            'Thank you for reaching out 💙 A counsellor will be with you shortly. You are not alone.',
        sender: MessageSender.system,
      );
    } else {
      // POC in-memory mode
      _mockSessions[id] = session;
      _mockMessages[id] = [];
      _broadcastWaiting();
      await _addMockMessage(
        sessionId: id,
        text: 'Thank you for reaching out 💙 A counsellor will be with you shortly. You are not alone.',
        sender: MessageSender.system,
      );
    }
    return session;
  }

  Future<void> acceptSession({
    required String sessionId,
    required String counsellorId,
    required String counsellorName,
  }) async {
    final db = _db;
    if (db != null) {
      await db.collection('sessions').doc(sessionId).update({
        'counsellorId': counsellorId,
        'counsellorName': counsellorName,
        'status': ChatSessionStatus.active.name,
        'acceptedAt': Timestamp.fromDate(DateTime.now()),
      });
    } else {
      final s = _mockSessions[sessionId];
      if (s == null) return;
      _mockSessions[sessionId] = ChatSession(
        id: s.id,
        userAlias: s.userAlias,
        status: ChatSessionStatus.active,
        createdAt: s.createdAt,
        currentMood: s.currentMood,
        isUserPaid: s.isUserPaid,
        counsellorId: counsellorId,
        counsellorName: counsellorName,
        acceptedAt: DateTime.now(),
      );
      _broadcastSession(sessionId);
      _broadcastWaiting();
    }
  }

  Future<void> endSession(String sessionId) async {
    final db = _db;
    if (db != null) {
      await db.collection('sessions').doc(sessionId).update({
        'status': ChatSessionStatus.ended.name,
        'endedAt': Timestamp.fromDate(DateTime.now()),
      });
    } else {
      final s = _mockSessions[sessionId];
      if (s == null) return;
      _mockSessions[sessionId] = ChatSession(
        id: s.id,
        userAlias: s.userAlias,
        status: ChatSessionStatus.ended,
        createdAt: s.createdAt,
        currentMood: s.currentMood,
        isUserPaid: s.isUserPaid,
        counsellorId: s.counsellorId,
        counsellorName: s.counsellorName,
      );
      _broadcastSession(sessionId);
    }
  }

  Stream<ChatSession?> sessionStream(String sessionId) {
    final db = _db;
    if (db != null) {
      return db.collection('sessions').doc(sessionId).snapshots().map((doc) {
        if (!doc.exists) return null;
        return ChatSession.fromFirestore(doc);
      });
    }
    _sessionControllers[sessionId] ??=
        StreamController<ChatSession?>.broadcast();
    return _sessionControllers[sessionId]!.stream;
  }

  Stream<List<ChatSession>> waitingSessionsStream() {
    final db = _db;
    if (db != null) {
      return db
          .collection('sessions')
          .where('status', isEqualTo: ChatSessionStatus.waiting.name)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => ChatSession.fromFirestore(d)).toList());
    }
    return _waitingController.stream;
  }

  Stream<List<ChatSession>> activeCounsellorSessions(String counsellorId) {
    final db = _db;
    if (db != null) {
      return db
          .collection('sessions')
          .where('counsellorId', isEqualTo: counsellorId)
          .where('status', isEqualTo: ChatSessionStatus.active.name)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => ChatSession.fromFirestore(d)).toList());
    }
    _activeControllers[counsellorId] ??=
        StreamController<List<ChatSession>>.broadcast();
    return _activeControllers[counsellorId]!.stream;
  }

  // ── Messages ────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String sessionId,
    required String text,
    required MessageSender sender,
  }) async {
    final msg = ChatMessage(
      id: _uuid.v4(),
      sessionId: sessionId,
      text: text,
      sender: sender,
      timestamp: DateTime.now(),
    );
    final db = _db;
    if (db != null) {
      await db
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .doc(msg.id)
          .set(msg.toMap());
    } else {
      _mockMessages[sessionId] ??= [];
      _mockMessages[sessionId]!.add(msg);
      _broadcastMessages(sessionId);
    }
  }

  Future<void> _addMockMessage({
    required String sessionId,
    required String text,
    required MessageSender sender,
  }) async {
    _mockMessages[sessionId] ??= [];
    _mockMessages[sessionId]!.add(ChatMessage(
      id: _uuid.v4(),
      sessionId: sessionId,
      text: text,
      sender: sender,
      timestamp: DateTime.now(),
    ));
    _broadcastMessages(sessionId);
  }

  Stream<List<ChatMessage>> messagesStream(String sessionId) {
    final db = _db;
    if (db != null) {
      return db
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => ChatMessage.fromFirestore(d))
              .where((m) => !m.isDeleted)
              .toList());
    }
    _messageControllers[sessionId] ??=
        StreamController<List<ChatMessage>>.broadcast();
    // Emit existing messages immediately
    Future.microtask(() {
      final msgs = (_mockMessages[sessionId] ?? [])
          .where((m) => !m.isDeleted)
          .toList();
      _messageControllers[sessionId]?.add(msgs);
    });
    return _messageControllers[sessionId]!.stream;
  }

  Future<void> deleteMessage(String sessionId, String messageId) async {
    final db = _db;
    if (db != null) {
      await db
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .doc(messageId)
          .update({'isDeleted': true});
    } else {
      final msgs = _mockMessages[sessionId];
      if (msgs == null) return;
      final idx = msgs.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        msgs[idx] = ChatMessage(
          id: msgs[idx].id,
          sessionId: msgs[idx].sessionId,
          text: msgs[idx].text,
          sender: msgs[idx].sender,
          timestamp: msgs[idx].timestamp,
          isDeleted: true,
        );
        _broadcastMessages(sessionId);
      }
    }
  }
}
