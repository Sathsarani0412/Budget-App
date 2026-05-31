import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_screen.dart';
import 'splash_screen.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final figmaShadow = BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 4,
      offset: const Offset(0, 4),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F3),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),

            /// LOGO
            Image.asset(
              'assets/logo.png',
              height: size.height * 0.12,
            ),

            const SizedBox(height: 10),

            const Text(
              "Manage your money, make your\nlife better 💗",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const Spacer(),

            /// 🔥 PINK GLASS CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 250, 170, 191)
                          .withOpacity(0.55),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        figmaShadow,
                        BoxShadow(
                          color: const Color(0xFFFF83A5).withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// EMAIL
                        _inputField(
                          "Email address",
                          Icons.email,
                          figmaShadow,
                          controller: emailController,
                        ),

                        const SizedBox(height: 12),

                        /// PASSWORD
                        _inputField(
                          "Password",
                          Icons.lock,
                          figmaShadow,
                          obscure: true,
                          controller: passwordController,
                        ),

                        const SizedBox(height: 12),

                        /// CONFIRM PASSWORD
                        _inputField(
                          "Confirm Password",
                          Icons.lock,
                          figmaShadow,
                          obscure: true,
                          controller: confirmController,
                        ),

                        const SizedBox(height: 15),

                        /// SIGNUP BUTTON
                        _button(
                          text: "Sign Up",
                          shadow: figmaShadow,
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final confirm = confirmController.text.trim();

                            if (password != confirm) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Passwords do not match"),
                                ),
                              );
                              return;
                            }

                            try {
                              final user = await AuthService()
                                  .signUp(email, password);

                              if (user != null) {
                                await BackendService()
                                    .createUser(email: email);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Account created successfully 🎉"),
                                  ),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DashboardScreen()),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message ?? "Error")),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 15),

                        /// 🔹 WHITE LOGIN CARD
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [figmaShadow],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/pot.png',
                                    height: 40,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              /// LOGIN BUTTON
                              _button(
                                text: "Login",
                                shadow: figmaShadow,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SplashScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔹 INPUT FIELD (FIXED)
  Widget _inputField(
    String hint,
    IconData icon,
    BoxShadow shadow, {
    bool obscure = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [shadow],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon),
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

  /// 🔹 BUTTON
  Widget _button({
    required String text,
    required BoxShadow shadow,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [shadow],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFE759B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}