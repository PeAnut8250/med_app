import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../api_keys.dart';
import '../models/doctor_model.dart';

class DoctorMapScreen extends StatefulWidget {
  const DoctorMapScreen({super.key});

  @override
  State<DoctorMapScreen> createState() => _DoctorMapScreenState();
}

class _DoctorMapScreenState extends State<DoctorMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  
  static const Color primaryTeal = Color(0xFF26A9B1);
  
  // Mock data centered around Kolkata
  final List<Doctor> _nearbyDoctors = [
    Doctor(
      id: '1',
      name: 'Dr. Rajesh Verma',
      specialty: 'Orthopedist',
      imagePath: 'assets/image 18.png',
      rating: 4.8,
      reviews: 124,
      lat: 22.5726,
      lng: 88.3639,
    ),
    Doctor(
      id: '2',
      name: 'Dr. Sarita Singh',
      specialty: 'Gynecology',
      imagePath: 'assets/image 18.png',
      rating: 4.9,
      reviews: 89,
      lat: 22.5800,
      lng: 88.3700,
    ),
    Doctor(
      id: '3',
      name: 'Dr. Amit Das',
      specialty: 'Cardiologist',
      imagePath: 'assets/image 18.png',
      rating: 4.7,
      reviews: 156,
      lat: 22.5650,
      lng: 88.3550,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  void _loadCustomMarkers() {
    for (var doctor in _nearbyDoctors) {
      _markers.add(
        Marker(
          markerId: MarkerId(doctor.id),
          position: LatLng(doctor.lat, doctor.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(
            title: doctor.name,
            snippet: doctor.specialty,
          ),
          onTap: () {
            // Logic to sync with list if needed
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasApiKey = googleMapsApiKey.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // MAP LAYER WITH REPAINT BOUNDARY
          RepaintBoundary(
            child: hasApiKey 
              ? GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(22.5726, 88.3639),
                    zoom: 13,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                )
              : _buildMapPlaceholder(), // FALLBACK
          ),

          // TOP SEARCH BAR (Floating)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),

          // DRAGGABLE BOTTOM SHEET
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: const Color(0xFFF1F1F1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Live Map Tiles Unavailable\n(API Key Missing)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors, clinics...',
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.tune, color: primaryTeal),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby Doctors',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_nearbyDoctors.length} found',
                      style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: _nearbyDoctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildDoctorCard(_nearbyDoctors[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              doctor.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  doctor.specialty,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.rating}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      ' (${doctor.reviews} reviews)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: primaryTeal),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
