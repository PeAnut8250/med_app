import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'main_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 2. STARTUP LOGIC: Auto-Login Gate
  Future<Widget> getInitialScreen() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? loginTime = prefs.getInt('login_time');

      if (loginTime != null) {
        final int currentTime = DateTime.now().millisecondsSinceEpoch;
        final int sevenDaysInMillis = 7 * 24 * 60 * 60 * 1000;

        // If logged in within the last 7 days, go to Main app
        if (currentTime - loginTime < sevenDaysInMillis) {
          return const MainWrapper();
        }
      }
    } catch (e) {
      debugPrint('Error accessing shared preferences: $e');
    }
    
    // Default to onboarding if no valid session
    return const OnboardingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarelineMed App',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          return snapshot.data ?? const OnboardingScreen();
        },
      ),
    );
  }
}
