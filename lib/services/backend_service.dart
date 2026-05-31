import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  /// 🔹 Create user document (after signup)
  Future<void> createUser({
    required String email,
  }) async {
    final name = email.split('@')[0]; // derive name

    await _db.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'currency': 'LKR',
    });
  }

  /// 🔹 Add transaction
  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    required DateTime date,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add({
      'type': type,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
    });
  }
}