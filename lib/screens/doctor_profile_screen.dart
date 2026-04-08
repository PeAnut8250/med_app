import 'package:flutter/material.dart';
import 'booking_flow_screen.dart';

class DoctorProfileView extends StatefulWidget {
  final Map<String, String> doctor;

  const DoctorProfileView({super.key, required this.doctor});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  int _selectedTabIndex = 0;
  String? _selectedTime;
  bool _isAboutExpanded = false;

  static const Color primaryTeal = Color(0xFF26A9B1);

  final List<String> _tabs = ['Info', 'Availability', 'Education', 'Review'];
  
  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:50 AM',
    '12:30 PM', '03:00 PM', '04:30 PM'
  ];

  final List<String> _unavailableSlots = ['12:30 PM', '03:00 PM', '04:30 PM'];

  @override
  Widget build(BuildContext context) {
    // Optimization: Fixed height for the header to maintain aspect ratio across screens
    const double expandedHeaderHeight = 350.0;

    return Scaffold(
      key: const ValueKey('doctor_profile_sanitized_v3'),
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildStickyFooter(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sanitized Header (Real Components + Cropped Asset)
          _buildSliverAppBar(expandedHeaderHeight),

          // 2. Statistics Row (Actual Native Widgets)
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 32),
                _buildContentSheet(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(double expandedHeight) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryTeal,
      // REAL BUTTONS: Replaced baked-in icons with high-fidelity Flutter widgets
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: _buildCircularIcon(
            icon: Icons.chevron_left,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: _buildCircularIcon(
              icon: Icons.bookmark_border,
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // NEW ASSET: Using 'doctor_rajesh.png' as requested
            Image.asset(
              'assets/doctor_rajesh.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
            
            // Dynamic Gradient Overlay for depth and text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),

            // REAL TEXT OVERLAY: Positioned optimally to replace/cover baked-in labels
            _buildImageOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOverlay() {
    return Positioned(
      left: 24,
      bottom: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Orthopedic specialist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.doctor['name'] ?? 'Medical Expert',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                '₹500',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Text(
                '/session',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIcon({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 26),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('Experience', '15 years', Icons.work_outline),
          _buildStatCard('Patients', '1000+', Icons.people_outline),
          _buildStatCard('Ratings', '4.8', Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered for cleaner stats alignment
        children: [
          Icon(icon, color: primaryTeal.withValues(alpha: 0.6), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSheet() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final bool isSelected = _selectedTabIndex == entry.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 13),
                children: [
                  TextSpan(
                    text: _isAboutExpanded 
                        ? 'An orthopedic doctor is a medical specialist who focuses on diagnosing, treating, and preventing conditions related to the musculoskeletal system. This includes bones, joints, muscles, ligaments, tendons, and nerves. They treat a wide variety of issues ranging from sports injuries to congenital disorders and degenerative diseases like arthritis. '
                        : 'An orthopedic doctor is a medical specialist who focuses on diagnosing, treating, and preventing conditions related to the musculoskeletal system. ...',
                  ),
                  TextSpan(
                    text: _isAboutExpanded ? ' Less' : ' More',
                    style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(
                    '6 March, Tuesday',
                    style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_month_outlined, color: Colors.black87, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _timeSlots.map((time) {
              final bool isUnavailable = _unavailableSlots.contains(time);
              final bool isSelected = _selectedTime == time;
              return _buildTimeChip(time, isSelected, isUnavailable);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time, bool isSelected, bool isUnavailable) {
    Color bgColor = Colors.white;
    Color textColor = primaryTeal;
    Border border = Border.all(color: primaryTeal.withValues(alpha: 0.5));
    if (isSelected) {
      bgColor = primaryTeal;
      textColor = Colors.white;
      border = Border.all(color: primaryTeal);
    } else if (isUnavailable) {
      bgColor = const Color(0xFFF0F0F0);
      textColor = Colors.grey[400]!;
      border = Border.all(color: Colors.transparent);
    }
    return GestureDetector(
      onTap: isUnavailable ? null : () => setState(() => _selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: border,
        ),
        child: Text(
          time,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_outlined, color: Colors.black87, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingFlowScreen(doctor: widget.doctor),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    'Book now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
