import 'package:flutter/material.dart';
import 'booking_flow_screen.dart';
import 'notifications_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/notification_bell.dart';

class DoctorProfileView extends StatefulWidget {
  final Map<String, String> doctor;

  const DoctorProfileView({super.key, required this.doctor});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  String _selectedTab = 'Info';
  String? _selectedTime;
  bool _isAboutExpanded = false;
  bool _isBookmarked = false;

  static const Color primaryTeal = Color(0xFF26A9B1);

  final List<String> _tabs = ['Info', 'Availability', 'Education', 'Review'];
  
  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:50 AM',
    '12:30 PM', '03:00 PM', '04:30 PM'
  ];

  final List<String> _unavailableSlots = ['12:30 PM', '03:00 PM', '04:30 PM'];

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_doctors') ?? [];
    setState(() {
      _isBookmarked = bookmarks.any((item) {
        final doc = json.decode(item);
        return doc['name'] == widget.doctor['name'];
      });
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_doctors') ?? [];
    
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      bookmarks.add(json.encode(widget.doctor));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor added to bookmarks!'), duration: Duration(seconds: 1)),
      );
    } else {
      bookmarks.removeWhere((item) => json.decode(item)['name'] == widget.doctor['name']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor removed from bookmarks'), duration: Duration(seconds: 1)),
      );
    }
    
    await prefs.setStringList('bookmarked_doctors', bookmarks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('doctor_profile_view_${widget.doctor['name']}'),
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildStickyFooter(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: const Offset(0, -35),
                  child: Container(
                    padding: const EdgeInsets.only(top: 25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoContent(),
                        _buildContentSheet(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryTeal,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _isBookmarked ? Colors.amber : Colors.white,
            size: 26,
          ),
          onPressed: _toggleBookmark,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.asset(
                'assets/doctor_rajesh.png',
                fit: BoxFit.cover,
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor['name'] ?? 'Medical Expert',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SENIOR ORTHOPEDIC SPECIALIST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal.withOpacity(0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '₹500',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                        const Text(
                          '/hr',
                          style: TextStyle(fontSize: 12, color: primaryTeal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildStatsRow(),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Experience', '15 years', Icons.work_outline),
        const SizedBox(width: 8),
        _buildStatCard('Patients', '1000+', Icons.people_outline),
        const SizedBox(width: 8),
        _buildStatCard('Ratings', '4.8', Icons.star_outline),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: primaryTeal, size: 20),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
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
              children: _tabs.map((tab) {
                final bool isSelected = _selectedTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          tab,
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
          const SizedBox(height: 32),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Availability':
        return _buildAvailabilityTab();
      case 'Education':
        return _buildEducationTab();
      case 'Review':
        return _buildReviewTab();
      case 'Info':
      default:
        return _buildInfoTab();
    }
  }

  Widget _buildInfoTab() {
    return Column(
      key: const ValueKey('Info'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildAvailabilityTab() {
    return Column(
      key: const ValueKey('Availability'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Working Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildAvailabilityRow('Monday - Friday', '09:00 AM - 05:00 PM'),
        _buildAvailabilityRow('Saturday', '10:30 AM - 02:00 PM'),
        _buildAvailabilityRow('Sunday', 'Emergency Only'),
        const SizedBox(height: 32),
        const Text('Next Available Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Dr. Rajesh is currently seeing patients. Next priority slot available in 20 minutes.', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
      ],
    );
  }

  Widget _buildAvailabilityRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
          Text(time, style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return Column(
      key: const ValueKey('Education'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Credentials & Learning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildEducationItem('MBBS', 'Medical College of Excellence (2005-2010)', 'Gold Medallist in Surgery'),
        _buildEducationItem('MS Orthopedics', 'London School of Medicine (2011-2014)', 'Specialized in Joint Replacements'),
        _buildEducationItem('Board Certified', 'American Board of Orthopedic Surgery', 'Since 2016'),
      ],
    );
  }

  Widget _buildEducationItem(String degree, String school, String highlight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.school, color: primaryTeal, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(degree, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(school, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text(highlight, style: const TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return Column(
      key: const ValueKey('Review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patient Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildReviewCard('Sarah Jenkins', 'Expert was very patient and explained the recovery process clearly.', 5),
        _buildReviewCard('Michael Ross', 'Best orthopedist I have visited. The staff is also great.', 4),
        _buildReviewCard('Emily Blunt', 'Highly recommended for knee issues.', 5),
      ],
    );
  }

  Widget _buildReviewCard(String name, String comment, int rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.amber,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time, bool isSelected, bool isUnavailable) {
    Color bgColor = Colors.white;
    Color textColor = primaryTeal;
    Border border = Border.all(color: primaryTeal.withOpacity(0.5));
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
            color: Colors.black.withOpacity(0.05),
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
