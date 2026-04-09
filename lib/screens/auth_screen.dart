import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_wrapper.dart';
import '../legal_data.dart';
import 'legal_content_screen.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  int _calculateStrength(String password) {
    if (password.isEmpty) return -1;
    if (password.length < 6) return 0; // Weak
    
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    
    if (password.length >= 8 && hasNumber && hasSpecial && hasUpper) return 2; // Strong
    if (password.length >= 6 && hasNumber) return 1; // Fair
    
    return 0; // Weak fallback
  }

  int _getPasswordStrength() {
    return _calculateStrength(_passwordController.text);
  }

  static const Color primaryTeal = Color(0xFF26A9B1);

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LegalContentScreen(
              title: 'Terms of Service',
              content: termsText,
            ),
          ),
        );
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LegalContentScreen(
              title: 'Privacy Policy',
              content: privacyText,
            ),
          ),
        );
      };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
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
                const SizedBox(height: 30),
                _buildFooterText(),
                const SizedBox(height: 20),
                _buildLegalLinksText(),
                const SizedBox(height: 10),
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
        Container(
          width: 220,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
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
            color: Colors.black.withOpacity(0.05),
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
              onTap: () => _showForgotPasswordSheet(),
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
          hint: '+91 98765 43210',
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
          onChanged: (val) => setState(() {}), // Trigger strength update
        ),
        const SizedBox(height: 12),
        _buildPasswordStrengthMeter(),
        const SizedBox(height: 20),
        const Text(
          'Confirm Password',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _confirmPasswordController,
          hint: '••••••••',
          prefixIcon: Icons.lock_reset_outlined,
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
            if (_passwordController.text != _confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
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
    Widget? prefixWidget,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: prefixWidget ?? Icon(prefixIcon, color: Colors.grey),
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

  Widget _buildPasswordStrengthMeter({String? customPassword}) {
    int strength = customPassword != null ? _calculateStrength(customPassword) : _getPasswordStrength();
    if (strength == -1) return const SizedBox.shrink();

    String label = strength == 0 ? 'Weak' : (strength == 1 ? 'Fair' : 'Strong');
    Color color = strength == 0 ? Colors.redAccent : (strength == 1 ? Colors.orangeAccent : Colors.greenAccent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                decoration: BoxDecoration(
                  color: index <= strength ? color : Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ForgotPasswordSheet(
        email: _emailController.text,
        phone: _phoneController.text,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successfully. Please login with your new credentials.')),
          );
        },
        calculateStrength: _calculateStrength,
        buildStrengthMeter: (pwd) => _buildPasswordStrengthMeter(customPassword: pwd),
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
          color: isSelected ? primaryTeal.withOpacity(0.08) : Colors.grey.withOpacity(0.05),
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
            color: primaryTeal.withOpacity(0.3),
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
            Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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

  Widget _buildLegalLinksText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.5),
          children: [
            const TextSpan(text: 'By signing in, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold),
              recognizer: _termsRecognizer,
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold),
              recognizer: _privacyRecognizer,
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordSheet extends StatefulWidget {
  final String email;
  final String phone;
  final VoidCallback onSuccess;
  final int Function(String) calculateStrength;
  final Widget Function(String) buildStrengthMeter;

  const ForgotPasswordSheet({
    required this.email,
    required this.phone,
    required this.onSuccess,
    required this.calculateStrength,
    required this.buildStrengthMeter,
  });

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  int _currentStep = 0; // 0: Selection, 1: ID, 2: OTP, 3: Reset, 4: Success
  String? _selectedMethod; // 'Email' or 'SMS'
  int _timerSeconds = 60;
  Timer? _timer;
  
  final TextEditingController _idController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if available
    if (widget.email.isNotEmpty) {
      _idController.text = widget.email;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _idController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
      if (_currentStep == 2) _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildStepContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildSelectionView();
      case 1: return _buildIdentificationView();
      case 2: return _buildOtpView();
      case 3: return _buildResetView();
      case 4: return _buildSuccessView();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildSelectionView() {
    return Column(
      children: [
        const Text('Forgot Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'How would you like to reset your password?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        _buildMethodCard(
          icon: Icons.email_outlined,
          title: 'via Email',
          subtitle: 'Receive code at your email',
          onTap: () {
            setState(() {
              _selectedMethod = 'Email';
              _idController.text = widget.email;
            });
            _nextStep();
          },
        ),
        const SizedBox(height: 16),
        _buildMethodCard(
          icon: Icons.sms_outlined,
          title: 'via SMS',
          subtitle: 'Receive code at your phone',
          onTap: () {
            setState(() {
              _selectedMethod = 'SMS';
              _idController.text = widget.phone;
            });
            _nextStep();
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildIdentificationView() {
    String label = _selectedMethod == 'Email' ? 'Email Address' : 'Phone Number';
    String hint = _selectedMethod == 'Email' ? 'Enter your email' : '+91 00000 00000';
    IconData icon = _selectedMethod == 'Email' ? Icons.email_outlined : Icons.phone_android_outlined;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(_selectedMethod == 'Email' ? 'Verify Email' : 'Verify Phone', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        Center(child: Text('We will send a code to your $_selectedMethod', style: const TextStyle(color: Colors.grey))),
        const SizedBox(height: 32),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSheetTextField(
          controller: _idController,
          hint: hint,
          prefixIcon: icon,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              if (_idController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter your $label')));
                return;
              }
              _nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A9B1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Send Code', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMethodCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF26A9B1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF26A9B1)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpView() {
    return Column(
      children: [
        const Text('Verify Code', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Enter the 4-digit code sent to ${_idController.text}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 60,
              height: 60,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF26A9B1), width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 3) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                    _nextStep();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        Text(
          _timerSeconds > 0 ? 'Resend code in ${_timerSeconds}s' : 'Didn\'t receive code?',
          style: const TextStyle(color: Colors.grey),
        ),
        if (_timerSeconds == 0)
          TextButton(
            onPressed: _startTimer,
            child: const Text('Resend Code', style: TextStyle(color: Color(0xFF26A9B1), fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildResetView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('Reset Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        const Center(child: Text('Create a secure new password', style: TextStyle(color: Colors.grey))),
        const SizedBox(height: 32),
        const Text('New Password', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSheetTextField(
          controller: _newPasswordController,
          hint: '••••••••',
          isPassword: true,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 12),
        widget.buildStrengthMeter(_newPasswordController.text),
        const SizedBox(height: 20),
        const Text('Confirm New Password', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSheetTextField(
          controller: _confirmPasswordController,
          hint: '••••••••',
          isPassword: true,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                return;
              }
              if (widget.calculateStrength(_newPasswordController.text) < 1) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please use a stronger password')));
                return;
              }
              _nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A9B1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
        ),
        const SizedBox(height: 24),
        const Text('Success!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Your password has been reset successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A9B1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Back to Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSheetTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    bool isPassword = false,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ) : null,
        ),
      ),
    );
  }
}


