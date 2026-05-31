import 'package:cloud_firestore/cloud_firestore.dart'
    show Timestamp;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_screen.dart';
import '../services/transaction_service.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  String selectedPeriod = "Monthly";
  String selectedFilter = "This Month";

  final service = TransactionService();

  final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 8,
    offset: const Offset(0, 5),
  );

  double _percent(double current, double last) {
    if (last == 0) return 0;
    return ((current - last) / last) * 100;
  }

  String _getInsight(double income, double expense, double lastExpense) {
    final saved = income - expense;

    if (saved > 0 && expense < lastExpense) {
      return "Great job! You saved Rs ${saved.toStringAsFixed(0)}.\nYou spent less than last month 👍";
    } else if (expense > income) {
      return "Warning! You are overspending ⚠️\nTry to reduce expenses.";
    } else {
      return "Keep tracking your finances.\nYou're doing okay.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F3),
      body: SafeArea(
        child: StreamBuilder(
          stream: service.getTransactions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            /// 🔥 CONVERT FIRESTORE → MAP
            final List<Map<String, dynamic>> converted =
                docs.map<Map<String, dynamic>>((doc) {
              final d = doc.data() as Map<String, dynamic>;

              return {
                "type": d["type"],
                "amount": (d["amount"] as num).toDouble(),
                "category": d["category"],
                "date": (d["date"] as Timestamp).toDate(),
              };
            }).toList();

            /// 🔥 FILTER
            final filtered =
                service.getFiltered(selectedFilter, converted);

            final totals = service.calculateTotals(filtered);
            final lastTotals =
                service.lastMonthTotals(converted);

            final income = totals["income"]!;
            final expense = totals["expense"]!;
            final lastIncome = lastTotals["income"]!;
            final lastExpense = lastTotals["expense"]!;

            final incomePercent = _percent(income, lastIncome);
            final expensePercent = _percent(expense, lastExpense);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// HEADER
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const DashboardScreen()),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFFFCDD7),
                          child: Icon(Icons.arrow_back, size: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("Analytics",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// FILTERS
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _filterButton("This Month"),
                      _filterButton("Last Month"),
                      _filterButton("This Year"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _card(
                          "Total Income",
                          "Rs ${income.toStringAsFixed(0)}",
                          "${incomePercent >= 0 ? "↑" : "↓"} ${incomePercent.toStringAsFixed(1)}%",
                          const Color(0xFFE8F8F0),
                          const Color(0xFF23B577),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _card(
                          "Total Expenses",
                          "Rs ${expense.toStringAsFixed(0)}",
                          "${expensePercent >= 0 ? "↑" : "↓"} ${expensePercent.toStringAsFixed(1)}%",
                          const Color(0xFFFEE0C6),
                          const Color(0xFFF8502E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// CHART HEADER
                  Row(
                    children: [
                      const Text("Income vs Expenses",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      DropdownButton<String>(
                        value: selectedPeriod,
                        items: const [
                          DropdownMenuItem(
                              value: "Monthly",
                              child: Text("Monthly")),
                          DropdownMenuItem(
                              value: "Weekly",
                              child: Text("Weekly")),
                        ],
                        onChanged: (v) {
                          setState(() => selectedPeriod = v!);
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// BAR CHART
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [shadow],
                    ),
                    child: SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          barGroups:
                              _getBarData(filtered),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// INSIGHT
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(15),
                      boxShadow: [shadow],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights,
                            color: Color(0xFFFE759B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getInsight(
                                income, expense, lastExpense),
                            style:
                                const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filterButton(String text) {
    final isSelected = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFE759B)
              : const Color(0xFFFFCDD7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [shadow],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color:
                isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _card(
      String title, String amount, String sub, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 5),
          Text(amount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 3),
          Text(sub,
              style: TextStyle(
                  fontSize: 11, color: color)),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarData(
      List<Map<String, dynamic>> data) {
    final values =
        service.getBarData(selectedPeriod, data);

    return List.generate(values.length, (i) {
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: values[i],
          color: const Color(0xFF23B577),
          width: 6,
        ),
        BarChartRodData(
          toY: values[i] * 0.6,
          color: const Color(0xFFF8502E),
          width: 6,
        ),
      ]);
    });
  }
}