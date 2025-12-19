/// Product model representing an item in the store
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviews = 0,
  });

  // Convert from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    double? rating,
    int? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
    );
  }
}
