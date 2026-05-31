import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 Initialize Firebase (IMPORTANT)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ✅ keep your existing screen
    );
  }
}