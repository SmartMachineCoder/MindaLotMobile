import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (cred.user == null) return null;

      final doc =
          await _db.collection('counsellors').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await _auth.signOut();
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
    await _auth.signOut();
  }

  User? get currentFirebaseUser => _auth.currentUser;
  bool get isCounsellorLoggedIn => _auth.currentUser != null;
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
