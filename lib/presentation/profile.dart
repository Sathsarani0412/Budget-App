import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController =
      TextEditingController(text: "Sandani");
  final TextEditingController emailController =
      TextEditingController(text: "sandani@gmail.com");

  final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 8,
    offset: const Offset(0, 5),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F3),

      body: SafeArea(
        child: Stack(
          children: [
            Padding(
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
                          child: Icon(Icons.arrow_back, size: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Center(
                    child: Text(
                      "Manage your account and preferences",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 PROFILE INFO
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFFFFCDD7),
                          child: Image.asset('assets/rabbit1.png'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nameController.text,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          emailController.text,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 EDIT PROFILE CARD
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE3EA),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [shadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                              color: Color(0xFFFE759B),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),

                        const SizedBox(height: 15),

                        /// NAME
                        const Text("Name"),
                        const SizedBox(height: 5),
                        _inputField(nameController),

                        const SizedBox(height: 10),

                        /// EMAIL
                        const Text("Email"),
                        const SizedBox(height: 5),
                        _inputField(emailController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 PREFERENCES
                  const Text("Preferences",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [shadow],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFCDD7),
                          child: Icon(Icons.attach_money),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Currency"),
                              Text("Set your preferred currency",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            /// 🔹 BOTTOM RABBIT IMAGE
            Positioned(
              bottom: 0,
              right: 10,
              child: Image.asset(
                'assets/rabbit2.png',
                height: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 INPUT FIELD WITH SHADOW
  Widget _inputField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [shadow],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFBB9CB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFBB9CB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFFE759B), width: 1.5),
          ),
        ),
      ),
    );
  }
}