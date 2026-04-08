import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/doctors_list_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late PageController _pageController;

  static const Color primaryTeal = Color(0xFF26A9B1);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Define screens in a getter to allow passing callbacks
  // Optimization: Wrapped each screen in RepaintBoundary to isolate GPU layers
  List<Widget> get _screens => [
    const RepaintBoundary(child: HomeScreen()),
    RepaintBoundary(
      child: DoctorsListScreen(
        onBackTap: () {
          _animateToTab(0);
        },
      ),
    ),
    const RepaintBoundary(
      child: Center(child: Text('Messages Screen Placeholder')),
    ),
    const RepaintBoundary(
      child: Center(child: Text('Profile Screen Placeholder')),
    ),
  ];

  void _animateToTab(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250), // Optimization: Snappier duration
      curve: Curves.fastOutSlowIn, // Optimization: Natural responsive curve
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Disabled swipe physics to prevent gesture conflicts with the Live Map
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
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
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.people_outline, 'Doctors', 1),
          _buildNavItem(Icons.chat_bubble_outline, 'Chat', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _animateToTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // Match snappy duration
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
