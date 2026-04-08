import 'package:flutter/material.dart';
import 'auth_screen.dart';
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Your clean background image
          Positioned.fill(
            child: Image.asset(
              'assets/first.png', // Make sure you export the background without text!
              fit: BoxFit.cover,
            ),
          ),

          // 2. The Text Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // Space from top
                  const Text(
                    'Your Health,\nOur Priority',
                    style: TextStyle(
                      color: Color(0xFF26A9B1),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Book appointments. Consult doctors.\nAnytime, anywhere.',
                    style: TextStyle(
                      color: const Color(0xFF26A9B1).withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

         // 3. The Interactive Slider Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50, left: 24, right: 24),
              child: const SliderButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class SliderButton extends StatefulWidget {
  const SliderButton({super.key});

  @override
  State<SliderButton> createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton> {
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;

      return Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Stack(
          children: [
            const Center(
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Color(0xFF26A9B1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragValue = (_dragValue + details.delta.dx).clamp(0.0, maxWidth - 110.0);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragValue > (maxWidth - 150)) {
                  setState(() => _dragValue = maxWidth - 110.0);
                  // Navigation to Auth
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                } else {
                  setState(() => _dragValue = 0.0);
                }
              },
              child: Transform.translate(
                offset: Offset(_dragValue, 0),
                child: Container(
                  width: 110,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A9B1),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: const Icon(Icons.keyboard_double_arrow_right, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}