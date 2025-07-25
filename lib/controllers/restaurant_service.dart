// lib/controllers/restaurant_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';
import '../models/meal.dart';

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();
  factory RestaurantService() => _instance;
  RestaurantService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create restaurant profile (called when restaurant user signs up)
  Future<bool> createRestaurantProfile({
    required String userId,
    required String name,
    required String cuisine,
    required String address,
    required String description,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('restaurants').doc(userId).set({
        'id': userId,
        'name': name,
        'cuisine': cuisine,
        'address': address,
        'description': description,
        'imageUrl': imageUrl ?? 'https://via.placeholder.com/300x200?text=Restaurant',
        'rating': 0.0,
        'totalRatings': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creating restaurant profile: $e');
      return false;
    }
  }

  // Get all active restaurants
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final querySnapshot = await _firestore
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      List<Restaurant> restaurants = [];
      for (var doc in querySnapshot.docs) {
        final restaurantData = doc.data();
        
        // Get menu for this restaurant
        final menuSnapshot = await _firestore
            .collection('restaurants')
            .doc(doc.id)
            .collection('menu')
            .where('isAvailable', isEqualTo: true)
            .get();
        
        List<Meal> menu = menuSnapshot.docs.map((menuDoc) {
          return Meal.fromMap(menuDoc.data(), menuDoc.id);
        }).toList();

        restaurants.add(Restaurant(
          id: doc.id,
          name: restaurantData['name'] ?? '',
          imageUrl: restaurantData['imageUrl'] ?? '',
          cuisine: restaurantData['cuisine'] ?? '',
          rating: (restaurantData['rating'] ?? 0.0).toDouble(),
          address: restaurantData['address'] ?? '',
          description: restaurantData['description'] ?? '',
          menu: menu,
        ));
      }
      return restaurants;
    } catch (e) {
      print('Error getting restaurants: $e');
      return [];
    }
  }

  // Get restaurant by ID
  Future<Restaurant?> getRestaurantById(String restaurantId) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
      if (!doc.exists) return null;

      final restaurantData = doc.data()!;
      
      // Get menu for this restaurant
      final menuSnapshot = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .where('isAvailable', isEqualTo: true)
          .get();
      
      List<Meal> menu = menuSnapshot.docs.map((menuDoc) {
        return Meal.fromMap(menuDoc.data(), menuDoc.id);
      }).toList();

      return Restaurant(
        id: doc.id,
        name: restaurantData['name'] ?? '',
        imageUrl: restaurantData['imageUrl'] ?? '',
        cuisine: restaurantData['cuisine'] ?? '',
        rating: (restaurantData['rating'] ?? 0.0).toDouble(),
        address: restaurantData['address'] ?? '',
        description: restaurantData['description'] ?? '',
        menu: menu,
      );
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // Update restaurant profile
  Future<bool> updateRestaurantProfile({
    required String restaurantId,
    String? name,
    String? cuisine,
    String? address,
    String? description,
    String? imageUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (cuisine != null) updateData['cuisine'] = cuisine;
      if (address != null) updateData['address'] = address;
      if (description != null) updateData['description'] = description;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;

      await _firestore.collection('restaurants').doc(restaurantId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating restaurant profile: $e');
      return false;
    }
  }

  // Add meal to restaurant menu
  Future<bool> addMealToMenu({
    required String restaurantId,
    required String name,
    required String description,
    required double price,
    required bool isMeal,
    required List<String> ingredients,
    String? imageUrl,
  }) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .add({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl ?? 'https://via.placeholder.com/300x200?text=Food',
        'isMeal': isMeal,
        'ingredients': ingredients,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding meal to menu: $e');
      return false;
    }
  }

  // Update meal in restaurant menu
  Future<bool> updateMeal({
    required String restaurantId,
    required String mealId,
    String? name,
    String? description,
    double? price,
    bool? isMeal,
    List<String>? ingredients,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (isMeal != null) updateData['isMeal'] = isMeal;
      if (ingredients != null) updateData['ingredients'] = ingredients;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;

      await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .doc(mealId)
          .update(updateData);
      return true;
    } catch (e) {
      print('Error updating meal: $e');
      return false;
    }
  }

  // Delete meal from restaurant menu
  Future<bool> deleteMeal({
    required String restaurantId,
    required String mealId,
  }) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .doc(mealId)
          .update({
        'isAvailable': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error deleting meal: $e');
      return false;
    }
  }

  // Get restaurant menu
  Future<List<Meal>> getRestaurantMenu(String restaurantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Meal.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting restaurant menu: $e');
      return [];
    }
  }

  // Update restaurant rating
  Future<void> updateRestaurantRating(String restaurantId, double newRating) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final currentRating = (data['rating'] ?? 0.0).toDouble();
        final totalRatings = (data['totalRatings'] ?? 0).toInt();
        
        final newTotalRatings = totalRatings + 1;
        final updatedRating = ((currentRating * totalRatings) + newRating) / newTotalRatings;
        
        await _firestore.collection('restaurants').doc(restaurantId).update({
          'rating': updatedRating,
          'totalRatings': newTotalRatings,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating restaurant rating: $e');
    }
  }
}