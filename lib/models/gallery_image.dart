class GalleryImage {
  final String id;
  final String imagePath;
  final String name;
  final DateTime uploadedAt;

  GalleryImage({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.uploadedAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'name': name,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      name: json['name'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
}
