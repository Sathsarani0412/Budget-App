import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  /// 🔹 ADD TRANSACTION
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

  /// 🔹 GET STREAM
  Stream<QuerySnapshot> getTransactions() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // =========================================================
  // ✅ FILTER DATA (USED IN VIEW.DART)
  // =========================================================
  List<Map<String, dynamic>> getFiltered(
  String filter,
  List<Map<String, dynamic>> data,
) {

  final now = DateTime.now();

  return data.where((t) {

    final date =
        t['date'] as DateTime;

    if (filter == "This Week") {

      return date.isAfter(
        now.subtract(
          const Duration(days: 7),
        ),
      );
    }

    else if (filter == "Last Week") {

      return date.isAfter(
        now.subtract(
          const Duration(days: 14),
        ),
      ) &&
          date.isBefore(
            now.subtract(
              const Duration(days: 7),
            ),
          );
    }

    else if (filter == "This Month") {

      return date.month == now.month &&
          date.year == now.year;
    }

    else if (filter == "Last Month") {

      final lastMonth =
          DateTime(now.year, now.month - 1);

      return date.month == lastMonth.month &&
          date.year == lastMonth.year;
    }

    else if (filter == "This Year") {

      return date.year == now.year;
    }

    return true;

  }).toList();
}

  // =========================================================
  // ✅ TOTALS
  // =========================================================
  Map<String, double> calculateTotals(
      List<Map<String, dynamic>> data) {
    double income = 0;
    double expense = 0;

    for (var t in data) {
      if (t['type'] == "income") {
        income += (t['amount'] as num).toDouble();
      } else {
        expense += (t['amount'] as num).toDouble();
      }
    }

    return {
      "income": income,
      "expense": expense,
    };
  }

  // =========================================================
  // ✅ LAST MONTH TOTALS
  // =========================================================
  Map<String, double> lastMonthTotals(
      List<Map<String, dynamic>> data) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);

    double income = 0;
    double expense = 0;

    for (var t in data) {
      final date = t['date'] as DateTime;

      if (date.month == lastMonth.month &&
          date.year == lastMonth.year) {
        if (t['type'] == "income") {
          income += (t['amount'] as num).toDouble();
        } else {
          expense += (t['amount'] as num).toDouble();
        }
      }
    }

    return {
      "income": income,
      "expense": expense,
    };
  }

  // =========================================================
  // ✅ BAR DATA (INCOME ONLY)
  // =========================================================
  List<double> getBarData(
      String period, List<Map<String, dynamic>> data) {
    if (period == "Weekly") {
      List<double> weekly = [0, 0, 0, 0];

      for (var t in data) {
        final date = t['date'] as DateTime;
        int week = ((date.day - 1) ~/ 7).clamp(0, 3);

        if (t['type'] == "income") {
          weekly[week] += (t['amount'] as num).toDouble();
        }
      }

      return weekly;
    } else {
      // Monthly grouped into 5 sections
      List<double> monthly = [0, 0, 0, 0, 0];

      for (var t in data) {
        final date = t['date'] as DateTime;
        int index = ((date.month - 1) ~/ 2).clamp(0, 4);

        if (t['type'] == "income") {
          monthly[index] += (t['amount'] as num).toDouble();
        }
      }

      return monthly;
    }
  }

  // =========================================================
  // ✅ CATEGORY TOTALS (FOR PIE CHART)
  // =========================================================
  Map<String, double> categoryTotals(
      List<Map<String, dynamic>> data) {
    Map<String, double> result = {};

    for (var t in data) {
      if (t['type'] == "expense") {
        final category = t['category'];

        result[category] =
            (result[category] ?? 0) +
                (t['amount'] as num).toDouble();
      }
    }

    return result;
  }
}