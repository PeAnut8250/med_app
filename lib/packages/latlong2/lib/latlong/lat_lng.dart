import 'dart:math' as math;

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(double latitude, double longitude)
      : latitude = latitude < -90.0 ? -90.0 : (latitude > 90.0 ? 90.0 : latitude),
        longitude = longitude < -180.0
            ? (longitude % 360.0 + 360.0) % 360.0 - 180.0
            : (longitude > 180.0 ? (longitude % 360.0 + 360.0) % 360.0 - 180.0 : longitude);

  @override
  String toString() => 'LatLng(latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  double get latitudeInRad => latitude * (math.pi / 180.0);
  double get longitudeInRad => longitude * (math.pi / 180.0);

  LatLng.fromJson(Map<String, dynamic> json)
      : latitude = (json['lat'] ?? 0.0) as double,
        longitude = (json['lng'] ?? 0.0) as double;

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
      };
}
