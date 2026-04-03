import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/mood.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

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
    await _db.collection('sessions').doc(id).set(session.toMap());

    // Send automated first message
    await sendMessage(
      sessionId: id,
      text:
          'Thank you for reaching out 💙 A counsellor will be with you shortly. You are not alone.',
      sender: MessageSender.system,
    );
    return session;
  }

  Future<void> acceptSession({
    required String sessionId,
    required String counsellorId,
    required String counsellorName,
  }) async {
    await _db.collection('sessions').doc(sessionId).update({
      'counsellorId': counsellorId,
      'counsellorName': counsellorName,
      'status': ChatSessionStatus.active.name,
      'acceptedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> endSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).update({
      'status': ChatSessionStatus.ended.name,
      'endedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<ChatSession?> sessionStream(String sessionId) {
    return _db.collection('sessions').doc(sessionId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatSession.fromFirestore(doc);
    });
  }

  /// Counsellor: stream of all waiting sessions
  Stream<List<ChatSession>> waitingSessionsStream() {
    return _db
        .collection('sessions')
        .where('status', isEqualTo: ChatSessionStatus.waiting.name)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatSession.fromFirestore(d)).toList());
  }

  /// Counsellor: stream of active sessions for a specific counsellor
  Stream<List<ChatSession>> activeCounsellorSessions(String counsellorId) {
    return _db
        .collection('sessions')
        .where('counsellorId', isEqualTo: counsellorId)
        .where('status', isEqualTo: ChatSessionStatus.active.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatSession.fromFirestore(d)).toList());
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
    await _db
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(msg.id)
        .set(msg.toMap());
  }

  Stream<List<ChatMessage>> messagesStream(String sessionId) {
    return _db
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

  Future<void> deleteMessage(String sessionId, String messageId) async {
    await _db
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(messageId)
        .update({'isDeleted': true});
  }
}
