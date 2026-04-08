library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong2.dart';

// --- Improved Mercator Projection ---

class MercatorProjection {
  static const double tileSize = 256.0;

  static math.Point<double> project(LatLng latLng, double zoom) {
    final n = math.pow(2.0, zoom);
    final x = (latLng.longitude + 180.0) / 360.0 * n;
    final y = (1.0 - math.log(math.tan(latLng.latitudeInRad) + 1.0 / math.cos(latLng.latitudeInRad)) / math.pi) / 2.0 * n;
    return math.Point(x * tileSize, y * tileSize);
  }
}

// --- Dynamic Map Core ---

class FlutterMap extends StatefulWidget {
  final MapOptions options;
  final List<Widget> children;

  const FlutterMap({
    super.key,
    required this.options,
    required this.children,
  });

  @override
  State<FlutterMap> createState() => _FlutterMapState();
}

class _FlutterMapState extends State<FlutterMap> {
  late MapCamera camera;

  @override
  void initState() {
    super.initState();
    camera = MapCamera(
      center: widget.options.initialCenter,
      zoom: widget.options.initialZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MapInheritedWidget(
      camera: camera,
      child: Stack(
        clipBehavior: Clip.none,
        children: widget.children,
      ),
    );
  }
}

class _MapInheritedWidget extends InheritedWidget {
  final MapCamera camera;
  const _MapInheritedWidget({required this.camera, required super.child});

  @override
  bool updateShouldNotify(_MapInheritedWidget oldWidget) => camera != oldWidget.camera;

  static _MapInheritedWidget? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MapInheritedWidget>();
}

// --- Config ---

class MapOptions {
  final LatLng initialCenter;
  final double initialZoom;
  final InteractionOptions interactionOptions;

  const MapOptions({
    required this.initialCenter,
    this.initialZoom = 13.0,
    this.interactionOptions = const InteractionOptions(),
  });
}

class InteractionOptions {
  final int flags;
  const InteractionOptions({this.flags = 0});
}

class InteractiveFlag {
  static const int all = 1;
  static const int rotate = 2;
}

class MapCamera {
  final LatLng center;
  final double zoom;
  const MapCamera({required this.center, required this.zoom});
}

// --- Live CartoDB Tile Engine ---

class TileLayer extends StatelessWidget {
  final String urlTemplate;
  final String userAgentPackageName;

  const TileLayer({
    super.key,
    required this.urlTemplate,
    this.userAgentPackageName = '',
  });

  @override
  Widget build(BuildContext context) {
    final camera = _MapInheritedWidget.of(context)!.camera;
    final zoom = camera.zoom.floor();
    
    // Calculate central tile coordinates
    final n = math.pow(2.0, zoom).toInt();
    final xCenter = ((camera.center.longitude + 180.0) / 360.0 * n).floor();
    final yCenter = ((1.0 - math.log(math.tan(camera.center.latitudeInRad) + 1.0 / math.cos(camera.center.latitudeInRad)) / math.pi) / 2.0 * n).floor();

    return Container(
      color: const Color(0xFFF0F2F3), // Neutral background
      child: Stack(
        children: [
          // Build a 5x5 Grid for a seamless background
          for (int dx = -2; dx <= 2; dx++)
            for (int dy = -2; dy <= 2; dy++)
              Positioned(
                left: (MediaQuery.of(context).size.width / 2) + (dx * 256.0) - 128,
                top: (MediaQuery.of(context).size.height / 2) + (dy * 256.0) - 128,
                child: Image.network(
                  // Use CartoDB Light Basemap (Fast & Reliable)
                  'https://basemaps.cartocdn.com/light_all/$zoom/${xCenter + dx}/${yCenter + dy}.png',
                  width: 256,
                  height: 256,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 256,
                    height: 256,
                    color: const Color(0xFFE5E8EB),
                    child: const Icon(Icons.grid_on, color: Colors.grey, size: 16),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// --- Live Marker Layer ---

class MarkerLayer extends StatelessWidget {
  final List<Marker> markers;
  const MarkerLayer({super.key, required this.markers});

  @override
  Widget build(BuildContext context) {
    final camera = _MapInheritedWidget.of(context)!.camera;
    final centerProj = MercatorProjection.project(camera.center, camera.zoom);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: markers.map((m) {
        final mProj = MercatorProjection.project(m.point, camera.zoom);
        final x = (screenWidth / 2) + (mProj.x - centerProj.x);
        final y = (screenHeight / 2) + (mProj.y - centerProj.y);

        return Positioned(
          left: x - (m.width / 2),
          top: y - (m.height / 2),
          child: m.child,
        );
      }).toList(),
    );
  }
}

class Marker {
  final LatLng point;
  final Widget child;
  final double width;
  final double height;

  const Marker({
    required this.point,
    required this.child,
    this.width = 30.0,
    this.height = 30.0,
  });
}
