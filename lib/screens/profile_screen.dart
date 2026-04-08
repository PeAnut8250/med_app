import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_screen.dart';
import 'profile_sub_screens.dart';
import 'notifications_screen.dart';
import '../widgets/notification_bell.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  const ProfileScreen({super.key, this.onBackTap});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  String _userName = 'Alexander Bennett';
  String _userContact = '+1 (555) 012-3456 • alex.b@email.com';
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  static const Color primaryTeal = Color(0xFF26A9B1);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Alexander Bennett';
      String email = prefs.getString('user_email') ?? 'no-email@careline.com';
      String phone = prefs.getString('user_phone') ?? 'No phone added';
      _userContact = email != 'no-email@careline.com' ? '$phone • $email' : 'Tap to update contact info';
      
      String? imagePath = prefs.getString('user_profile_image');
      if (imagePath != null) {
        _profileImage = XFile(imagePath);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile_image', pickedFile.path);
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Profile Picture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerBtn(Icons.camera_alt_outlined, 'Take Photo', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildPickerBtn(Icons.image_outlined, 'Gallery', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: primaryTeal, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildMenuSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularBtn(Icons.chevron_left, () {
            if (widget.onBackTap != null) {
              widget.onBackTap!();
            } else {
              Navigator.pop(context);
            }
          }),
          const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          NotificationBell(
            hasNotification: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBtn(IconData icon, VoidCallback onTap, {bool hasBadge = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Center(
          child: Stack(
            children: [
              Icon(icon, color: Colors.black87, size: 24),
              if (hasBadge) Positioned(right: 0, top: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryTeal, width: 3)),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _profileImage != null 
                    ? NetworkImage(_profileImage!.path) as ImageProvider
                    : const AssetImage('assets/Profile.png'),
                  child: _profileImage == null && !AssetImage('assets/Profile.png').hashCode.isNegative // Placeholder fallback
                    ? null 
                    : null,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 4),
        Text(_userContact, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Personal Information', onTap: () async {
            final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditPersonalInformationScreen()));
            if (updated == true) _loadUserData();
          }),
          _buildMenuItem(Icons.account_tree_outlined, 'Family Members', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFamilyMemberScreen()))),
          _buildMenuItem(Icons.payment_outlined, 'Payment Methods', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()))),
          _buildMenuItem(Icons.history, 'Appointment History', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentHistoryScreen()))),
          _buildMenuItem(Icons.settings_outlined, 'Settings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          _buildMenuItem(Icons.help_outline, 'Help & Support'),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.logout, 'Logout', isDestructive: true, onTap: _handleLogout),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (isDestructive ? Colors.red : const Color(0xFFF5F5F5)), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: (isDestructive ? Colors.white : Colors.black54), size: 20)),
              const SizedBox(width: 16),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : Colors.black87)),
              const Spacer(),
              Icon(Icons.chevron_right, color: isDestructive ? Colors.red.withValues(alpha: 0.5) : Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
