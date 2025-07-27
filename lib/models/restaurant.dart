// lib/models/restaurant.dart
import 'dart:convert';

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String cuisine;
  final double rating;
  final String address;
  final String description;
  final int totalRatings;
  final bool isActive;
  final DateTime createdAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisine,
    required this.rating,
    required this.address,
    required this.description,
    this.totalRatings = 0,
    this.isActive = true,
    required this.createdAt,
  });

  // Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'cuisine': cuisine,
      'rating': rating,
      'address': address,
      'description': description,
      'totalRatings': totalRatings,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map (local storage)
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      cuisine: map['cuisine'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      totalRatings: map['totalRatings'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Convert to JSON string for storage
  String toJson() => json.encode(toMap());

  // Create from JSON string
  factory Restaurant.fromJson(String source) => Restaurant.fromMap(json.decode(source));

  // Copy with method for updates
  Restaurant copyWith({
    String? name,
    String? imageUrl,
    String? cuisine,
    double? rating,
    String? address,
    String? description,
    int? totalRatings,
    bool? isActive,
  }) {
    return Restaurant(
      id: id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      cuisine: cuisine ?? this.cuisine,
      rating: rating ?? this.rating,
      address: address ?? this.address,
      description: description ?? this.description,
      totalRatings: totalRatings ?? this.totalRatings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}