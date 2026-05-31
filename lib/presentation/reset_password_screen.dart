import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final emailController = TextEditingController();
  bool isLoading = false;

  final auth = AuthService();

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

            /// 🔹 LOGO
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

            /// 🔥 CARD
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
                      ),
                      boxShadow: [
                        figmaShadow,
                        BoxShadow(
                          color: const Color(0xFFFF83A5)
                              .withOpacity(0.25),
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
                            "Reset Password",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// EMAIL ONLY (IMPORTANT)
                        _inputField(
                          "Email address",
                          Icons.email,
                          figmaShadow,
                          controller: emailController,
                        ),

                        const SizedBox(height: 15),

                        /// RESET BUTTON
                        _button(
                          text: isLoading ? "Sending..." : "Send Reset Link",
                          shadow: figmaShadow,
                          onPressed: _resetPassword,
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

  /// 🔥 RESET FUNCTION
  void _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await auth.sendPasswordResetEmail(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reset link sent to email 📧"),
        ),
      );

      Navigator.pop(context); // go back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error sending email"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  /// 🔹 INPUT FIELD
  Widget _inputField(
    String hint,
    IconData icon,
    BoxShadow shadow, {
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [shadow],
      ),
      child: TextField(
        controller: controller,
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