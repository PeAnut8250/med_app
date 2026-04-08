import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_profile_screen.dart';
import 'notifications_screen.dart';
import '../widgets/notification_bell.dart';
import '../models/service_model.dart';
import 'service_detail_screen.dart';
class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();

  static const Color primaryTeal = Color(0xFF26A9B1);
  static const Color backgroundGray = Color(0xFFF8F9FA);

  // Data
  final List<Map<String, String>> _categories = [
    {'name': 'Gynecology', 'icon': 'assets/Frame 2.png'},
    {'name': 'Orthopedist', 'icon': 'assets/Frame 3.png'},
    {'name': 'General Surgery', 'icon': 'assets/Frame 7.png'},
    // {'name': 'Cardiology', 'icon': 'assets/Frame 8.png'}, // Disabled for now
  ];

  final List<Map<String, String>> _doctors = [
    {'name': 'Dr. Rajesh Verma', 'specialty': 'Orthopedist', 'experience': '6 year experience', 'image': 'assets/image 18.png'},
    {'name': 'Dr. Sarita Singh', 'specialty': 'Gynecology', 'experience': '8 year experience', 'image': 'assets/image 18.png'},
    // {'name': 'Dr. Amit Kumar', 'specialty': 'Cardiology', 'experience': '10 year experience', 'image': 'assets/image 18.png'},
  ];

  late List<Map<String, String>> _filteredDoctors;

  final List<ServiceModel> _services = [
    ServiceModel(
      name: 'DENTAL CLINIC',
      tagline: 'Premium Dental Care',
      imagePath: 'assets/dental_service.png',
      description: 'Our dental clinic offers a full range of services from routine checkups to complex surgeries. We utilize the latest technology to ensure your smile remains bright and healthy.',
      subServices: ['Root Canal', 'Teeth Whitening', 'Dental Braces', 'Implants'],
    ),
    ServiceModel(
      name: 'SURGERY',
      tagline: 'Advanced Surgical Center',
      imagePath: 'assets/surgery_service.png',
      description: 'State-of-the-art surgical facilities with a focus on minimally invasive procedures. Our expert surgeons are dedicated to providing the highest standard of patient care.',
      subServices: ['General Surgery', 'Urology', 'Orthopedics', 'Plastic Surgery'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredDoctors = _doctors;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDoctors = _doctors
          .where((doc) =>
              doc['name']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              doc['specialty']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<String> _getUserName() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_name') ?? 'Guest';
    } catch (e) {
      debugPrint('Error reading user name: $e');
      return 'Guest';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      color: backgroundGray,
      child: SingleChildScrollView(
        // Optimization: Removed redundant outer RepaintBoundary that was causing compositor lag
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildCategories(),
            _buildBanners(),
            _buildSuggestedDoctors(),
            _buildFeaturedServices(),
            const SizedBox(height: 120), 
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'CARELINE',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'MED',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Happiness is good care',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onProfileTap,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NotificationBell(
                          backgroundColor: Colors.transparent,
                          iconColor: Colors.orange,
                          hasNotification: true,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                        ),
                        const SizedBox(width: 8),
                        // Optimization: Caching profile image decode size
                        CircleAvatar(
                          radius: 18, 
                          backgroundImage: ResizeImage(
                            const AssetImage('assets/Profile.png'),
                            width: 100, // Pre-scale for circle avatar
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Hello,', style: TextStyle(color: Colors.white, fontSize: 24)),
          FutureBuilder<String>(
            future: _getUserName(),
            builder: (context, snapshot) {
              String name = snapshot.data ?? 'Guest';
              return Text(
                '$name!',
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Doctors',
                hintStyle: TextStyle(color: Colors.grey),
                icon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('See All', style: TextStyle(color: primaryTeal)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140, 
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped ${_categories[index]['name']}')),
                  );
                },
                child: Column(
                  children: [
                    // Optimization: Caching category icons to small size
                    Image.asset(
                      _categories[index]['icon']!,
                      height: 100,
                      width: 100,
                      cacheWidth: 200, 
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _categories[index]['name']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBanners() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildBannerCard(title: 'Physical Appointment', subtitle: 'At Hospital', image: 'assets/image 32.png')),
          const SizedBox(width: 16),
          Expanded(child: _buildBannerCard(title: 'Instant Video Consult', subtitle: 'Connect in 5 sec', image: 'assets/image 30.png')),
        ],
      ),
    );
  }

  Widget _buildBannerCard({required String title, required String subtitle, required String image}) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Interacting with $title')),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5, // Optimization: Lighter GPU load
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(15),
                ),
                child: Image.asset(
                  image,
                  height: 125,
                  cacheHeight: 300, // Optimization: Avoid full size decode
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedDoctors() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Suggested Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('See All', style: TextStyle(color: primaryTeal)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filteredDoctors.asMap().entries.map((entry) {
                final doc = entry.value;
                return Padding(
                  padding: EdgeInsets.only(right: entry.key == _filteredDoctors.length - 1 ? 0 : 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorProfileView(doctor: doc),
                        ),
                      );
                    },
                    child: DoctorCard(
                      name: doc['name']!,
                      specialty: doc['specialty']!,
                      experience: doc['experience']!,
                      image: doc['image']!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: primaryTeal))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _services.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final service = _services[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailScreen(service: service),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Optimization: Use cacheWidth for service background image
                          Positioned.fill(
                            child: Hero(
                              tag: 'service_image_${service.name}',
                              child: Image.asset(
                                service.imagePath,
                                cacheWidth: 600,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(color: primaryTeal),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  service.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  service.tagline,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            top: 16,
                            right: 16,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 12,
                              child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String experience;
  final String image;

  const DoctorCard({super.key, required this.name, required this.specialty, required this.experience, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 180,
      margin: const EdgeInsets.only(bottom: 10, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5, // Optimization: Lighter GPU load
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  specialty,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.work_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      experience,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF26A9B1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF26A9B1),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              color: Color(0xFF26A9B1),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Image.asset(
              image,
              height: 160,
              cacheHeight: 400, // Optimization: Forced small decode size
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }
}
