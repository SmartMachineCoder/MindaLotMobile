import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase is optional — app runs in POC mode without it
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // ── User (anonymous session) ─────────────────────────────────────────────

  Future<String> getUserAlias() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userAlias') ?? 'Friend';
  }

  Future<void> setUserAlias(String alias) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAlias', alias);
  }

  Future<bool> isUserPaid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isUserPaid') ?? false;
  }

  // ── Counsellor Auth ──────────────────────────────────────────────────────

  Future<CounsellorUser?> signInCounsellor(String email, String password) async {
    final auth = _auth;
    final db = _db;
    if (auth == null || db == null) {
      // POC mode: accept a demo counsellor login without Firebase
      if (email == 'counsellor@mindalot.com' && password == 'test1234') {
        return CounsellorUser(
          uid: 'demo-counsellor-001',
          name: 'Demo Counsellor',
          email: email,
          role: 'counsellor',
        );
      }
      return null;
    }
    try {
      final cred = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (cred.user == null) return null;

      final doc =
          await db.collection('counsellors').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await auth.signOut();
        return null;
      }
      final data = doc.data()!;
      return CounsellorUser(
        uid: cred.user!.uid,
        name: data['name'] ?? 'Counsellor',
        email: email,
        role: data['role'] ?? 'counsellor',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> signOutCounsellor() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
  }

  User? get currentFirebaseUser => _auth?.currentUser;
  bool get isCounsellorLoggedIn => _auth?.currentUser != null;
}

class CounsellorUser {
  final String uid;
  final String name;
  final String email;
  final String role;

  CounsellorUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });
}
