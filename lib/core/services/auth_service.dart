import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final _firestore = FirebaseFirestore.instance;

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static Future<String> getUserRole() async {
    final uid = currentUser?.uid;
    if (uid == null) return 'WARGA';
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'WARGA';
  }

  static Future<bool> isAdmin() async {
    return (await getUserRole()) == 'ADMIN';
  }
}
