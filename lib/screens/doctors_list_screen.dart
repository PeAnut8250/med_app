import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';

class DoctorsListScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  const DoctorsListScreen({super.key, this.onBackTap});

  static const Color primaryTeal = Color(0xFF26A9B1);
  static const Color backgroundGray = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          // 1. Universal Stable Map Layer (Bottom) - CartoDB / OSM
          _buildFlutterMap(),

          // 2. Draggable Sheet Layer
          _buildDraggableSheet(),

          // 3. Top Overlay Layer (Header & Search)
          _buildTopOverlay(context),
        ],
      ),
    );
  }

  Widget _buildFlutterMap() {
    return Positioned.fill(
      child: RepaintBoundary(
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(-37.8136, 144.9631), // Melbourne
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
              Colors.black.withValues(alpha: 0.4),
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
                  iconColor: Colors.black,
                  onPressed: onBackTap ?? () => Navigator.pop(context),
                ),
                _buildCircularButton(
                  icon: Icons.notifications_none,
                  iconColor: Colors.black,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications pressed')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Floating Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
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
                        hintText: 'Search for doctors...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.mic, color: primaryTeal),
                  SizedBox(width: 8),
                  Icon(Icons.tune, color: primaryTeal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onPressed, Color iconColor = Colors.black}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 28),
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
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: Column(
            children: [
              // Pull Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suggested Doctors',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildDoctorListCard(context, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorListCard(BuildContext context, int index) {
    final List<String> names = [
      'Dr. Rajesh Kumar',
      'Dr. Ananya Sharma',
      'Dr. Michael Scott',
      'Dr. Sarah Jane',
    ];
    final List<String> specialties = [
      'Cardiologist',
      'Dentist',
      'Surgery',
      'Neurologist',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left: Portrait Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/doctor_rajesh.png',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Right: Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        names[index],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Icon(Icons.favorite_border, color: primaryTeal, size: 20),
                    ],
                  ),
                  Text(
                    specialties[index],
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Info Row
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text('5 Years Exp', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text('10 AM - 2 PM', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryTeal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Call', style: TextStyle(color: primaryTeal)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                          ),
                          child: const Text('Book Now'),
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
}
