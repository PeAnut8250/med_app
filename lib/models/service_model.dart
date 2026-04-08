class ServiceModel {
  final String name;
  final String tagline;
  final String imagePath;
  final String description;
  final List<String> subServices;

  ServiceModel({
    required this.name,
    required this.tagline,
    required this.imagePath,
    required this.description,
    required this.subServices,
  });
}
