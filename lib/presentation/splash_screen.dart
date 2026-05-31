import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'reset_password_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

            /// 🔥 LOGIN CARD
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
                        const Text(
                          "Welcome Back! 👋",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFE759B),
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          "Login to continue",
                          style: TextStyle(fontSize: 12),
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

                        const SizedBox(height: 10),

                        /// FORGOT PASSWORD
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ResetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFE759B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// LOGIN BUTTON
                        _button(
                          text: isLoading ? "Loading..." : "Login",
                          shadow: figmaShadow,
                          onPressed: _login,
                        ),

                        const SizedBox(height: 15),

                        /// SIGNUP BOX
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
                                    height: 45,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "New here?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Create an account and start your budget journey today!",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              _button(
                                text: "Sign Up",
                                shadow: figmaShadow,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
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

  /// 🔥 LOGIN FUNCTION
  void _login() async {
  setState(() => isLoading = true);

  try {
    final user = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {

    setState(() => isLoading = false);

    String msg = "Login Failed";

    if (e.code == 'user-not-found') {
      msg = "No account found";
    } else if (e.code == 'wrong-password') {
      msg = "Wrong password";
    } else if (e.code == 'invalid-email') {
      msg = "Invalid email";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
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