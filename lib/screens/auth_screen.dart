import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_wrapper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  String _selectedAccountType = 'Patient';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  static const Color primaryTeal = Color(0xFF26A9B1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4DB6AC), // Lighter teal at top
              Colors.white,      // Pure white at bottom
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 60),
                _buildAuthToggle(),
                const SizedBox(height: 40),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLogin ? _buildLoginForm() : _buildSignupForm(),
                ),
                const SizedBox(height: 30),
                _buildSocialLogins(),
                const SizedBox(height: 20),
                _buildFooterText(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CARELINE',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 1.0,
              ),
            ),
            const Text(
              'MED',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const Text(
          'Happiness is good care',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _isLogin ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.42,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = true),
                  // ADDED: Ensures the entire expanded area responds to taps
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: _isLogin ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = false),
                  // ADDED: Ensures the entire expanded area responds to taps
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Signup',
                      style: TextStyle(
                        color: !_isLogin ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hint: 'name@company.com',
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          obscureText: !_isPasswordVisible,
          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        const SizedBox(height: 40),
        _buildAuthButton(
          text: 'Sign In',
          onPressed: () async {
            // BASIC VALIDATION
            if (!_emailController.text.contains('@')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid email address')),
              );
              return;
            }
            if (_passwordController.text.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password must be at least 6 characters')),
              );
              return;
            }
            
            // 1. DATA STORAGE (Auto-Login Gate)
            try {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              
              // Extract name from email as fallback (e.g. dibakar.sen@gmail.com -> Dibakar)
              String namePart = _emailController.text.split('@')[0].split('.')[0];
              String displayName = namePart[0].toUpperCase() + namePart.substring(1).toLowerCase();
              
              await prefs.setString('user_name', displayName);
              await prefs.setString('user_email', _emailController.text.trim());
              // Use a default phone for login if not available, usually login wouldn't have it
              await prefs.setString('user_phone', '+1 (555) 000-0000');
              await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
            } catch (e) {
              debugPrint('Error saving preferences: $e');
            }

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainWrapper()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCOUNT TYPE',
          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const Text(
          'Who are you?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildAccountTypeCard(
          title: 'I am a Patient',
          desc: 'Access your health records and book appointments.',
          icon: Icons.person_outline,
          isSelected: _selectedAccountType == 'Patient',
          onTap: () => setState(() => _selectedAccountType = 'Patient'),
        ),
        const SizedBox(height: 16),
        _buildAccountTypeCard(
          title: 'I am a Doctor',
          desc: 'Manage your practice and connect with patients.',
          icon: Icons.medical_services_outlined,
          isSelected: _selectedAccountType == 'Doctor',
          onTap: () => setState(() => _selectedAccountType = 'Doctor'),
        ),
        const SizedBox(height: 30),
        const Text(
          'Full Name',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          hint: 'your name',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        const Text(
          'Phone Number',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _phoneController,
          hint: '+1 (555) 000-0000',
          prefixIcon: Icons.phone_android_outlined,
        ),
        const SizedBox(height: 20),
        const Text(
          'Email Address',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hint: 'name@company.com',
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        const Text(
          'Password',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          obscureText: !_isPasswordVisible,
          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        const SizedBox(height: 40),
        _buildAuthButton(
          text: 'Sign up',
          onPressed: () async {
            // BASIC VALIDATION
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter your full name')),
              );
              return;
            }
            if (!_emailController.text.contains('@')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid email address')),
              );
              return;
            }
            if (_passwordController.text.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password must be at least 6 characters')),
              );
              return;
            }

            // 1. DATA STORAGE (Persistence)
            try {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', _nameController.text.trim());
              await prefs.setString('user_email', _emailController.text.trim());
              await prefs.setString('user_phone', _phoneController.text.trim());
              await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
            } catch (e) {
              debugPrint('Error saving preferences: $e');
            }

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainWrapper()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String title,
    required String desc,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      // ADDED: Ensures the entire card area captures the tap even on empty space
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryTeal : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: primaryTeal, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          // Optimization: Exact match for container border radius
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLogins() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon('assets/google_icon.png', Icons.g_mobiledata),
            const SizedBox(width: 20),
            _buildSocialIcon('assets/fb_icon.png', Icons.facebook),
            const SizedBox(width: 20),
            _buildSocialIcon('assets/mail_icon.png', Icons.mail),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(String asset, IconData fallbackIcon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Icon(fallbackIcon, color: Colors.grey[700], size: 28),
    );
  }

  Widget _buildFooterText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account? " : "Already have an account? ",
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => setState(() => _isLogin = !_isLogin),
          child: Text(
            _isLogin ? "Sign up" : "Log in",
            style: const TextStyle(color: primaryTeal, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
