import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarelineMed App',
      debugShowCheckedModeBanner: false, // This removes that red DEBUG banner!
      home: const OnboardingScreen(),    // Start with onboarding
    );
  }
}