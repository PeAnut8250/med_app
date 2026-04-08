import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/consultation_screen.dart';
import 'screens/doctors_list_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late List<Widget> _screens;


  static const Color primaryTeal = Color(0xFF26A9B1);

  @override
  void initState() {
    super.initState();
    _screens = _buildScreens();
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        onProfileTap: () {
          if (_currentIndex == 4) return;
          _animateToTab(4);
        },
      ),
      ConsultationScreen(
        onBackTap: () => _animateToTab(0),
      ),
      DoctorsListScreen(
        onBackTap: () => _animateToTab(0),
      ),
      MessagesScreen(
        onBackTap: () => _animateToTab(0),
      ),
      ProfileScreen(
        onBackTap: () => _animateToTab(0),
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _animateToTab(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use AnimatedSwitcher for smooth cross-fade transitions
      body: Stack(
        fit: StackFit.expand,
        children: List.generate(_screens.length, (index) {
          final bool isActive = _currentIndex == index;
          return AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: IgnorePointer(
              ignoring: !isActive,
              child: RepaintBoundary(
                child: _screens[index],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(),
      extendBody: true, 
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 25, top: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5, // Optimization: Reduced blur for GPU performance
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.assignment_outlined, 'My Consultation', 1),
          _buildNavItem(Icons.medical_services_outlined, 'Doctors', 2),
          _buildNavItem(Icons.mail_outline, 'Messages', 3),
          _buildNavItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return InkResponse(
      onTap: () => _animateToTab(index),
      radius: 40,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), 
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : primaryTeal.withValues(alpha: 0.6),
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
