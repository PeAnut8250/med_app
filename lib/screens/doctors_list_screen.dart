import 'package:flutter/material.dart';
import 'doctor_profile_screen.dart';
import 'notifications_screen.dart';
import '../widgets/notification_bell.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';

class DoctorsListScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  const DoctorsListScreen({super.key, this.onBackTap});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isMapVisible = false;

  static const Color primaryTeal = Color(0xFF26A9B1);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isMapVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Optimization: Removed outer RepaintBoundary that was causing redundant layer compositing
    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          _isMapVisible ? _buildFlutterMap() : _buildMapPlaceholder(),
          _buildDraggableSheet(),
          _buildTopOverlay(context),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
        child: const Center(
          child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFlutterMap() {
    return Positioned.fill(
      child: RepaintBoundary(
        // Optimization: Keep this one as the Map is a heavy but relatively static GPU layer
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(-37.8136, 144.9631), 
            initialZoom: 13.5,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.carelinemed.app',
            ),
            MarkerLayer(
              markers: [
                _buildMapMarker(const LatLng(-37.8100, 144.9600)),
                _buildMapMarker(const LatLng(-37.8150, 144.9700)),
                _buildMapMarker(const LatLng(-37.8200, 144.9550)),
                _buildMapMarker(const LatLng(-37.8050, 144.9650)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildMapMarker(LatLng point) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: primaryTeal.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: primaryTeal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white, blurRadius: 4, spreadRadius: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                  icon: Icons.chevron_left,
                  onPressed: widget.onBackTap ?? () => Navigator.pop(context),
                ),
                NotificationBell(
                  hasNotification: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5, // Optimization: Lighter GPU load
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Doctors by name or department',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFilterChip(Icons.tune, 'Specialization', true),
                const SizedBox(width: 10),
                _buildFilterChip(null, 'Fees', false),
                const SizedBox(width: 10),
                _buildFilterChip(null, 'Availability', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(IconData? icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? primaryTeal : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isActive)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4, // Optimization: Ultra-light for chips
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: isActive ? Colors.white : primaryTeal, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2), // Optimization: Lighter GPU load
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final mockDoctor = {
                      'name': 'Dr. Rajesh Verma',
                      'specialty': 'Orthopedist',
                      'experience': '6 year experience',
                      'image': 'assets/image 18.png',
                    };
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorProfileView(doctor: mockDoctor),
                          ),
                        );
                      },
                      child: _buildDoctorListCard(mockDoctor),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorListCard(Map<String, String> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                doctor['image']!, 
                width: 90,
                height: 90,
                cacheWidth: 300, 
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        doctor['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Icon(Icons.favorite_border, color: Colors.redAccent.withValues(alpha: 0.8), size: 18),
                    ],
                  ),
                  Text(doctor['specialty']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.work_outline, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('6 year experience', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      SizedBox(width: 4),
                      Text('|', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      SizedBox(width: 4),
                      Icon(Icons.schedule, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('10 AM - 2 PM', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      SizedBox(width: 4),
                      Text('|', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      SizedBox(width: 4),
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      SizedBox(width: 2),
                      Text('5.0', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildActionCircle(Icons.call),
                      const SizedBox(width: 10),
                      _buildOutlineBookingButton(),
                      const Spacer(),
                      const Text(
                        '₹450',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryTeal.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.call, color: primaryTeal, size: 20),
    );
  }

  Widget _buildOutlineBookingButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: primaryTeal),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 14, color: primaryTeal),
          SizedBox(width: 6),
          Text(
            'Book Now',
            style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
