import 'package:flutter/material.dart';
import 'doctors_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation State
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryTeal = Color(0xFF26A9B1);
  static const Color backgroundGray = Color(0xFFF8F9FA);

  // Data
  final List<Map<String, String>> _categories = [
    {'name': 'Gynecology', 'icon': 'assets/Frame 2.png'},
    {'name': 'Orthopedist', 'icon': 'assets/Frame 3.png'},
    {'name': 'General Surgery', 'icon': 'assets/Frame 7.png'},
    {'name': 'Cardiology', 'icon': 'assets/Frame 8.png'},
  ];

  final List<Map<String, String>> _doctors = [
    {'name': 'Dr. Rajesh Verma', 'specialty': 'Orthopedist', 'experience': '6 year experience', 'image': 'assets/image 18.png'},
    {'name': 'Dr. Sarita Singh', 'specialty': 'Gynecology', 'experience': '8 year experience', 'image': 'assets/image 18.png'},
    {'name': 'Dr. Amit Kumar', 'specialty': 'Cardiology', 'experience': '10 year experience', 'image': 'assets/image 18.png'},
  ];

  late List<Map<String, String>> _filteredDoctors;

  final List<Map<String, String>> _services = [
    {'name': 'DENTAL CLINIC', 'icon': 'assets/dental_service.png', 'desc': 'Best quality treatments'},
    {'name': 'SURGERY', 'icon': 'assets/surgery_service.png', 'desc': 'Expert surgical care'},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildCategories(),
            _buildBanners(),
            _buildSuggestedDoctors(),
            _buildFeaturedServices(),
            const SizedBox(height: 100), 
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'CARELINE',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
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
                  const Text(
                    'Happiness is good care',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_none, color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/Profile.png')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Hello,', style: TextStyle(color: Colors.white, fontSize: 24)),
          const Text('Dibakar Sen!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
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
    final categories = [
      {'name': 'Gynecology', 'icon': 'assets/Frame 2.png'},
      {'name': 'Orthopedist', 'icon': 'assets/Frame 3.png'},
      {'name': 'General Surgery', 'icon': 'assets/Frame 7.png'},
      {'name': 'Cardiology', 'icon': 'assets/Frame 8.png'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorsListScreen()));
                },
                child: const Text('See All', style: TextStyle(color: primaryTeal)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150, 
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                highlightColor: Colors.black.withOpacity(0.05),
                splashColor: Colors.transparent,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped ${_categories[index]['name']}')),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: Image.asset(
                        _categories[index]['icon']!,
                        fit: BoxFit.contain,
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Interacting with $title')),
          );
        },
        borderRadius: BorderRadius.circular(15),
        highlightColor: Colors.black.withOpacity(0.05),
        splashColor: Colors.transparent,
        child: Container(
          height: 150, // Increased slightly for better layout
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
                  height: 125, // Increased from 100 to make the image more prominent
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
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
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorsListScreen()));
                },
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
                  child: DoctorCard(
                    name: doc['name']!,
                    specialty: doc['specialty']!,
                    experience: doc['experience']!,
                    image: doc['image']!,
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
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Service: ${_services[index]['name']}')),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    highlightColor: Colors.white.withOpacity(0.1),
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: primaryTeal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(_services[index]['icon']!),
                          fit: BoxFit.cover,
                          onError: (e, s) {},
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _services[index]['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  _services[index]['desc']!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Positioned(
                              top: 0,
                              right: 0,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', _currentIndex == 0, 0),
          _buildNavItem(Icons.medical_services_outlined, '', _currentIndex == 1, 1),
          _buildNavItem(Icons.mail_outline, '', _currentIndex == 2, 2),
          _buildNavItem(Icons.person_outline, '', _currentIndex == 3, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, int index) {
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorsListScreen()));
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : primaryTeal.withOpacity(0.6)),
            if (isActive && label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing profile of $name')),
          );
        },
        borderRadius: BorderRadius.circular(20),
        highlightColor: Colors.black.withOpacity(0.03),
        splashColor: Colors.transparent,
        child: Container(
      width: 300,
      height: 180, // Fixed height is required for the internal Spacer()
      margin: const EdgeInsets.only(bottom: 10, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text and Buttons Section
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling $name...')),
                          );
                        },
                        borderRadius: BorderRadius.circular(30),
                        highlightColor: Colors.white24,
                        child: Container(
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
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Booking appointment with $name')),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          highlightColor: const Color(0xFF26A9B1).withOpacity(0.1),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Doctor Image Section
          Expanded(
            flex: 4,
            child: Image.asset(
              image,
              height: 160,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    ),
   ),
  );
 }
}