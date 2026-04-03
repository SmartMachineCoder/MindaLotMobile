import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageSender { user, counsellor, system }

class ChatMessage {
  final String id;
  final String sessionId;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isDeleted;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isDeleted = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      text: data['text'] ?? '',
      sender: MessageSender.values.firstWhere(
        (e) => e.name == data['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'text': text,
        'sender': sender.name,
        'timestamp': Timestamp.fromDate(timestamp),
        'isDeleted': isDeleted,
      };
}

class ChatSession {
  final String id;
  final String userAlias;
  final String? counsellorId;
  final String? counsellorName;
  final ChatSessionStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? endedAt;
  final String? currentMood;
  final bool isUserPaid;

  ChatSession({
    required this.id,
    required this.userAlias,
    this.counsellorId,
    this.counsellorName,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.endedAt,
    this.currentMood,
    this.isUserPaid = false,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSession(
      id: doc.id,
      userAlias: data['userAlias'] ?? 'Anonymous',
      counsellorId: data['counsellorId'],
      counsellorName: data['counsellorName'],
      status: ChatSessionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ChatSessionStatus.waiting,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      currentMood: data['currentMood'],
      isUserPaid: data['isUserPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'userAlias': userAlias,
        'counsellorId': counsellorId,
        'counsellorName': counsellorName,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
        'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
        'currentMood': currentMood,
        'isUserPaid': isUserPaid,
      };
}

enum ChatSessionStatus { waiting, active, ended, missed }
