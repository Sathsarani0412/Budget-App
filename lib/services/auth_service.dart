import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 LOGIN
  Future<User?> login(String email, String password) async {
  final res = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  return res.user;
}

  /// 🔹 SIGNUP
  Future<User?> signUp(String email, String password) async {
    try {
      final res = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return res.user;
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 RESET PASSWORD (NEW)
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}