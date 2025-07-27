// lib/models/user.dart
import 'dart:convert';

enum UserRole {
  client,
  restaurant,
  deliveryAgent,
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final String? profileImageUrl;
  final bool isActive;
  
  // Role-specific fields
  final String? restaurantName; // For restaurant users
  final String? cuisine; // For restaurant users
  final String? address; // For restaurant and delivery agent users
  final String? licenseNumber; // For delivery agent users
  final String? vehicleType; // For delivery agent users
  final bool? isAvailable; // For delivery agent users

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.profileImageUrl,
    this.isActive = true,
    this.restaurantName,
    this.cuisine,
    this.address,
    this.licenseNumber,
    this.vehicleType,
    this.isAvailable,
  });

  // Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'restaurantName': restaurantName,
      'cuisine': cuisine,
      'address': address,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'isAvailable': isAvailable,
    };
  }

  // Create from Map (local storage)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.client,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? true,
      restaurantName: map['restaurantName'],
      cuisine: map['cuisine'],
      address: map['address'],
      licenseNumber: map['licenseNumber'],
      vehicleType: map['vehicleType'],
      isAvailable: map['isAvailable'],
    );
  }

  // Convert to JSON string for storage
  String toJson() => json.encode(toMap());

  // Create from JSON string
  factory AppUser.fromJson(String source) => AppUser.fromMap(json.decode(source));

  // Copy with method for updates
  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? profileImageUrl,
    bool? isActive,
    String? restaurantName,
    String? cuisine,
    String? address,
    String? licenseNumber,
    String? vehicleType,
    bool? isAvailable,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      restaurantName: restaurantName ?? this.restaurantName,
      cuisine: cuisine ?? this.cuisine,
      address: address ?? this.address,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

// Auth result class for authentication operations
class AuthResult {
  final bool success;
  final String? error;
  final AppUser? user;

  AuthResult({required this.success, this.error, this.user});
}