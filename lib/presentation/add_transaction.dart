import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isIncome = true;
  int selectedCategory = -1;

  final TextEditingController amountController = TextEditingController();

  final service = TransactionService();

  final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 8,
    offset: const Offset(0, 5),
  );

  final categories = [
    {"name": "Food", "icon": "assets/food.png"},
    {"name": "Travel", "icon": "assets/travel.png"},
    {"name": "Shopping", "icon": "assets/shopping.png"},
    {"name": "Rent", "icon": "assets/rent.png"},
    {"name": "Entertainment", "icon": "assets/entertainment.png"},
    {"name": "Bills", "icon": "assets/bill.png"},
    {"name": "Stationary", "icon": "assets/other.png"},
    {"name": "Other", "icon": "assets/other.png"},
  ];

  /// 🔥 UPDATED SUBMIT LOGIC (FIREBASE CONNECTED)
  void _submit() async {
    final amountText = amountController.text.trim();

    if (amountText.isEmpty) {
      _showMessage("Enter amount");
      return;
    }

    if (!isIncome && selectedCategory == -1) {
      _showMessage("Select a category");
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null) {
      _showMessage("Invalid amount");
      return;
    }

    final category =
        isIncome ? "Income" : categories[selectedCategory]["name"]!;

    try {
      await service.addTransaction(
        type: isIncome ? "income" : "expense",
        amount: amount,
        category: category,
        date: DateTime.now(),
      );

      _showMessage("Added successfully");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      _showMessage("Error: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFE759B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F3),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// 🔹 HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardScreen()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFFFFCDD7),
                      child: Icon(Icons.arrow_back,
                          size: 16, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Add Transaction",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 TOGGLE
              Row(
                children: [
                  _toggleButton("Income", true),
                  const SizedBox(width: 10),
                  _toggleButton("Expenses", false),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 AMOUNT
              const Text("Amount",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE3EA),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [shadow],
                ),
                child: Row(
                  children: [
                    const Text("Rs ",
                        style: TextStyle(
                            color: Color(0xFFFE759B), fontSize: 18)),

                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: "0.00",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    Image.asset("assets/pot.png", height: 45),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 CATEGORY
              if (!isIncome) ...[
                const Text("Expenses Category",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final isSelected = selectedCategory == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedCategory = index);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFFFE759B)
                                  : const Color(0xFFFFCDD7),
                              boxShadow: [shadow],
                            ),
                            child:
                                Image.asset(item["icon"]!, height: 22),
                          ),
                          const SizedBox(height: 5),
                          Text(item["name"]!,
                              style: const TextStyle(fontSize: 10))
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 20),

              /// 🔹 DATE
              const Text("Date",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE3EA),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [shadow],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 10),
                    Text(_getTodayLabel()),
                  ],
                ),
              ),

              const Spacer(),

              /// 🔹 ADD BUTTON
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFE759B),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [shadow],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Add Transaction",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 DATE LABEL (TODAY / TOMORROW STYLE)
  String _getTodayLabel() {
    final now = DateTime.now();
    return "Today ${now.day}/${now.month}/${now.year}";
  }

  /// 🔹 TOGGLE BUTTON
  Widget _toggleButton(String text, bool value) {
    final isSelected = isIncome == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isIncome = value;
            selectedCategory = -1;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFE759B)
                : const Color(0xFFFFCDD7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [shadow],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}