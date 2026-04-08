class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String imagePath;
  final double rating;
  final int reviews;
  final double lat;
  final double lng;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imagePath,
    required this.rating,
    required this.reviews,
    required this.lat,
    required this.lng,
  });
}
