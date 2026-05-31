import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'add_transaction.dart';
import 'view.dart';
import 'profile.dart';

import '../services/transaction_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  int selectedIndex = 0;

  String selectedFilter = "This Month";

  final service = TransactionService();

  double totalIncome = 0;
  double totalExpense = 0;

  double incomeChange = 0;
  double expenseChange = 0;

  Map<String, double> categoryData = {};

  /// CATEGORY ICONS
  final Map<String, String> categoryIcons = {
    "Food": "assets/food.png",
    "Travel": "assets/travel.png",
    "Shopping": "assets/shopping.png",
    "Rent": "assets/rent.png",
    "Entertainment": "assets/entertainment.png",
    "Bills": "assets/bill.png",
    "Stationary": "assets/other.png",
    "Other": "assets/other.png",
  };

  final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 8,
    offset: const Offset(0, 5),
  );

  // =====================================================
  // FILTER LOGIC
  // =====================================================

  bool _isInFilter(DateTime date) {
    final now = DateTime.now();

    if (selectedFilter == "This Week") {
      return date.isAfter(
        now.subtract(const Duration(days: 7)),
      );
    }

    else if (selectedFilter == "Last Week") {
      return date.isAfter(
        now.subtract(const Duration(days: 14)),
      ) &&
          date.isBefore(
            now.subtract(const Duration(days: 7)),
          );
    }

    else if (selectedFilter == "Last Month") {
      final lastMonth =
          DateTime(now.year, now.month - 1);

      return date.month == lastMonth.month &&
          date.year == lastMonth.year;
    }

    else if (selectedFilter == "This Year") {
      return date.year == now.year;
    }

    return date.month == now.month &&
        date.year == now.year;
  }

  // =====================================================
  // CALCULATE DATA
  // =====================================================

  void _calculateData(List docs) {

    totalIncome = 0;
    totalExpense = 0;

    incomeChange = 0;
    expenseChange = 0;

    categoryData.clear();

    double lastIncome = 0;
    double lastExpense = 0;

    final now = DateTime.now();

    for (var doc in docs) {

      final data = doc.data();

      final date =
          (data['date']).toDate();

      final type = data['type'];

      final amount =
          (data['amount'] as num)
              .toDouble();

      final category =
          data['category'];

      /// CURRENT FILTER
      if (_isInFilter(date)) {

        if (type == "income") {

          totalIncome += amount;

        } else {

          totalExpense += amount;

          categoryData[category] =
              (categoryData[category] ?? 0) +
                  amount;
        }
      }

      /// LAST MONTH
      final lastMonth =
          DateTime(now.year, now.month - 1);

      if (date.month == lastMonth.month &&
          date.year == lastMonth.year) {

        if (type == "income") {

          lastIncome += amount;

        } else {

          lastExpense += amount;
        }
      }
    }

    incomeChange = lastIncome == 0
        ? 100
        : ((totalIncome - lastIncome) /
                lastIncome) *
            100;

    expenseChange = lastExpense == 0
        ? 100
        : ((totalExpense - lastExpense) /
                lastExpense) *
            100;
  }

  // =====================================================
  // PIE CHART
  // =====================================================

  List<PieChartSectionData> _buildPie() {

    if (categoryData.isEmpty) {

      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          title: "No Data",
          radius: 60,
        ),
      ];
    }

    final total = categoryData.values
        .fold(0.0, (a, b) => a + b);

    final colors = [
      Colors.pink,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    int i = 0;

    return categoryData.entries.map((e) {

      final percent =
          (e.value / total) * 100;

      return PieChartSectionData(
        value: e.value,
        color:
            colors[i++ % colors.length],
        title:
            "${percent.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  String _getDateLabel() {

    final now = DateTime.now();

    return
        "${now.day}/${now.month}/${now.year}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F1F3),

      body: SafeArea(

        child: StreamBuilder(

          stream:
              service.getTransactions(),

          builder: (context, snapshot) {

            if (!snapshot.hasData) {

              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            final docs =
                snapshot.data!.docs;

            _calculateData(docs);

            final balance =
                totalIncome -
                    totalExpense;

            return Column(

              children: [

                Expanded(

                  child:
                      SingleChildScrollView(

                    child: Column(

                      children: [

                        const SizedBox(height: 10),

                        // =================================
                        // HEADER
                        // =================================

                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          20),

                          child: Row(

                            children: [

                              const Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(
                                      "Hi Welcome",

                                      style: TextStyle(
                                        color: Color(
                                            0xFFFE759B),
                                        fontSize: 16,
                                      ),
                                    ),

                                    SizedBox(
                                        height: 2),

                                    Text(
                                      "User",

                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                  Icons
                                      .notifications_none),

                              const SizedBox(
                                  width: 10),

                              CircleAvatar(
                                backgroundColor:
                                    Colors.pink
                                        .shade100,

                                child: Image.asset(
                                  'assets/rabbit2.png',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // =================================
                        // DROPDOWN
                        // =================================

                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          20),

                          child:
                              Container(

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 15,
                            ),

                            decoration:
                                BoxDecoration(

                              color: Colors.white,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          15),

                              boxShadow: [
                                shadow
                              ],
                            ),

                            child:
                                DropdownButtonHideUnderline(

                              child:
                                  DropdownButton<String>(

                                value:
                                    selectedFilter,

                                isExpanded:
                                    true,

                                items: [

                                  "This Week",

                                  "Last Week",

                                  "This Month",

                                  "Last Month",

                                  "This Year",

                                ].map((e) {

                                  return DropdownMenuItem(

                                    value: e,

                                    child:
                                        Text(e),
                                  );
                                }).toList(),

                                onChanged:
                                    (value) {

                                  setState(() {

                                    selectedFilter =
                                        value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // =================================
                        // BALANCE CARD
                        // =================================

                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          20),

                          child: Container(

                            padding:
                                const EdgeInsets
                                    .all(16),

                            decoration:
                                BoxDecoration(

                              color: const Color(
                                  0xFFFFA0B5),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          20),

                              boxShadow: [
                                shadow
                              ],
                            ),

                            child: Row(

                              children: [

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(
                                          "Total Balance"),

                                      const SizedBox(
                                          height: 5),

                                      Text(

                                        "Rs ${balance.toStringAsFixed(2)}",

                                        style:
                                            const TextStyle(
                                          fontSize:
                                              20,

                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 5),

                                      Row(
                                        children: [

                                          const Icon(
                                            Icons
                                                .calendar_today,
                                            size: 14,
                                          ),

                                          const SizedBox(
                                              width:
                                                  5),

                                          Text(
                                            _getDateLabel(),

                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Image.asset(
                                  'assets/rabbit1.png',
                                  height: 75,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // =================================
                        // INCOME EXPENSE CARDS
                        // =================================

                        Padding(

                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          20),

                          child: Row(

                            children: [

                              // =======================
                              // INCOME
                              // =======================

                              Expanded(

                                child:
                                    Container(

                                  padding:
                                      const EdgeInsets
                                          .all(
                                              12),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        const Color(
                                            0xFFE8F8F0),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                15),

                                    boxShadow: [
                                      shadow
                                    ],
                                  ),

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(

                                        "Total Income",

                                        style:
                                            TextStyle(
                                          color: Color(
                                              0xFF23B577),
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 5),

                                      Text(

                                        "Rs ${totalIncome.toStringAsFixed(2)}",

                                        style:
                                            const TextStyle(

                                          fontWeight:
                                              FontWeight
                                                  .bold,

                                          color: Color(
                                              0xFF23B577),
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 3),

                                      Row(
                                        children: [

                                          Icon(

                                            incomeChange >=
                                                    0
                                                ? Icons
                                                    .arrow_upward
                                                : Icons
                                                    .arrow_downward,

                                            size:
                                                12,

                                            color:
                                                const Color(
                                                    0xFF23B577),
                                          ),

                                          const SizedBox(
                                              width:
                                                  4),

                                          Expanded(
                                            child:
                                                Text(

                                              "${incomeChange.abs().toStringAsFixed(0)}% ${incomeChange >= 0 ? "increase" : "decrease"}",

                                              style:
                                                  const TextStyle(

                                                fontSize:
                                                    11,

                                                color:
                                                    Color(0xFF23B577),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 10),

                              // =======================
                              // EXPENSE
                              // =======================

                              Expanded(

                                child:
                                    Container(

                                  padding:
                                      const EdgeInsets
                                          .all(
                                              12),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        const Color(
                                            0xFFFEE0C6),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                15),

                                    boxShadow: [
                                      shadow
                                    ],
                                  ),

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(

                                        "Total Expenses",

                                        style:
                                            TextStyle(
                                          color: Color(
                                              0xFFF8502E),
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 5),

                                      Text(

                                        "Rs ${totalExpense.toStringAsFixed(2)}",

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 3),

                                      Row(
                                        children: [

                                          Icon(

                                            expenseChange >=
                                                    0
                                                ? Icons
                                                    .arrow_upward
                                                : Icons
                                                    .arrow_downward,

                                            size:
                                                12,

                                            color:
                                                const Color(
                                                    0xFFF8502E),
                                          ),

                                          const SizedBox(
                                              width:
                                                  4),

                                          Expanded(
                                            child:
                                                Text(

                                              "${expenseChange.abs().toStringAsFixed(0)}% ${expenseChange >= 0 ? "increase" : "decrease"}",

                                              style:
                                                  const TextStyle(

                                                fontSize:
                                                    11,

                                                color:
                                                    Color(0xFFF8502E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =================================
                        // TITLE
                        // =================================

                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                                  horizontal: 20),

                          child: Row(
                            children: [

                              Text(

                                "Expenses Overview",

                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // =================================
                        // PIE CHART
                        // =================================

                        Padding(

                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          20),

                          child: SizedBox(

                            height: 220,

                            child: PieChart(

                              PieChartData(

                                sections:
                                    _buildPie(),

                                centerSpaceRadius:
                                    40,

                                sectionsSpace:
                                    3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =================================
                        // CATEGORY LIST
                        // =================================

                        Padding(

                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          20),

                          child: Column(

                            children:
                                categoryData.entries
                                    .map((e) {

                              final percent =
                                  totalExpense == 0
                                      ? 0
                                      : (e.value /
                                              totalExpense) *
                                          100;

                              return Container(

                                margin:
                                    const EdgeInsets
                                        .only(
                                            bottom:
                                                12),

                                padding:
                                    const EdgeInsets
                                        .all(14),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors.white,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              18),

                                  boxShadow: [
                                    shadow
                                  ],
                                ),

                                child: Row(

                                  children: [

                                    Container(

                                      padding:
                                          const EdgeInsets
                                              .all(
                                                  10),

                                      decoration:
                                          const BoxDecoration(

                                        color: Color(
                                            0xFFFFE3EA),

                                        shape:
                                            BoxShape
                                                .circle,
                                      ),

                                      child:
                                          Image.asset(

                                        categoryIcons[
                                                e.key] ??
                                            "assets/other.png",

                                        height:
                                            22,

                                        width:
                                            22,
                                      ),
                                    ),

                                    const SizedBox(
                                        width:
                                            12),

                                    Expanded(

                                      child:
                                          Column(

                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [

                                          Text(

                                            e.key,

                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(
                                              height:
                                                  4),

                                          Text(

                                            "Rs ${e.value.toStringAsFixed(2)}",

                                            style:
                                                const TextStyle(

                                              color:
                                                  Colors.grey,

                                              fontSize:
                                                  12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(

                                      "${percent.toStringAsFixed(0)}%",

                                      style:
                                          const TextStyle(

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        color: Color(
                                            0xFFFE759B),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // ==========================================
      // BOTTOM NAV BAR
      // ==========================================

      bottomNavigationBar: Container(

        padding:
            const EdgeInsets.symmetric(
                vertical: 8),

        decoration: BoxDecoration(

          color: Colors.white,

          boxShadow: [shadow],
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [

            _navItem(
                Icons.home,
                "Home",
                0),

            _navItem(
                Icons.add,
                "Add Transaction",
                1),

            _navItem(
                Icons.bar_chart,
                "View",
                2),

            _navItem(
                Icons.person,
                "Profile",
                3),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // NAV ITEM
  // =====================================================

  Widget _navItem(
      IconData icon,
      String label,
      int index) {

    final isSelected =
        selectedIndex == index;

    return GestureDetector(

      onTap: () {

        setState(() {
          selectedIndex = index;
        });

        if (index == 1) {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const AddTransactionScreen(),
            ),
          );
        }

        else if (index == 2) {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const ViewScreen(),
            ),
          );
        }

        else if (index == 3) {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const ProfileScreen(),
            ),
          );
        }
      },

      child: Column(

        mainAxisSize:
            MainAxisSize.min,

        children: [

          Icon(
            icon,

            color: isSelected
                ? const Color(
                    0xFFFE759B)
                : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(

            label,

            style: TextStyle(

              fontSize: 10,

              color: isSelected
                  ? const Color(
                      0xFFFE759B)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}