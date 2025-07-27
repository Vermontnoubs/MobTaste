// lib/controllers/restaurant_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../models/meal.dart';

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();
  factory RestaurantService() => _instance;
  RestaurantService._internal();

  static const String _restaurantsKey = 'restaurants';
  static const String _mealsKey = 'meals';

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
      final restaurant = Restaurant(
        id: userId,
        name: name,
        cuisine: cuisine,
        address: address,
        description: description,
        imageUrl: imageUrl ?? 'https://via.placeholder.com/300x200?text=Restaurant',
        rating: 0.0,
        totalRatings: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _saveRestaurant(restaurant);
      return true;
    } catch (e) {
      print('Error creating restaurant profile: $e');
      return false;
    }
  }

  // Get all active restaurants
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final restaurants = await _getAllStoredRestaurants();
      // Add some sample restaurants if none exist
      if (restaurants.isEmpty) {
        await _initializeSampleRestaurants();
        return await _getAllStoredRestaurants();
      }
      return restaurants.where((r) => r.isActive).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
    } catch (e) {
      print('Error getting restaurants: $e');
      return [];
    }
  }

  // Get restaurant by ID
  Future<Restaurant?> getRestaurantById(String restaurantId) async {
    try {
      final restaurants = await _getAllStoredRestaurants();
      return restaurants.firstWhere((r) => r.id == restaurantId);
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // Get restaurant by user ID
  Future<Restaurant?> getRestaurantByUserId(String userId) async {
    return await getRestaurantById(userId);
  }

  // Update restaurant info
  Future<bool> updateRestaurant({
    required String restaurantId,
    String? name,
    String? cuisine,
    String? address,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    try {
      final restaurants = await _getAllStoredRestaurants();
      final index = restaurants.indexWhere((r) => r.id == restaurantId);
      
      if (index != -1) {
        final restaurant = restaurants[index];
        final updatedRestaurant = restaurant.copyWith(
          name: name,
          cuisine: cuisine,
          address: address,
          description: description,
          imageUrl: imageUrl,
          isActive: isActive,
        );
        
        restaurants[index] = updatedRestaurant;
        await _saveAllRestaurants(restaurants);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating restaurant: $e');
      return false;
    }
  }

  // Get meals for a restaurant
  Future<List<Meal>> getMealsForRestaurant(String restaurantId) async {
    try {
      final meals = await _getAllStoredMeals();
      final restaurantMeals = meals.where((m) => m.restaurantId == restaurantId && m.isAvailable).toList();
      
      // Add sample meals if none exist for this restaurant
      if (restaurantMeals.isEmpty) {
        await _initializeSampleMeals(restaurantId);
        final updatedMeals = await _getAllStoredMeals();
        return updatedMeals.where((m) => m.restaurantId == restaurantId && m.isAvailable).toList();
      }
      
      return restaurantMeals;
    } catch (e) {
      print('Error getting meals: $e');
      return [];
    }
  }

  // Add meal to restaurant
  Future<String?> addMeal({
    required String restaurantId,
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final mealId = DateTime.now().millisecondsSinceEpoch.toString();
      final meal = Meal(
        id: mealId,
        restaurantId: restaurantId,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl ?? 'https://via.placeholder.com/300x200?text=Meal',
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      await _saveMeal(meal);
      return mealId;
    } catch (e) {
      print('Error adding meal: $e');
      return null;
    }
  }

  // Update meal
  Future<bool> updateMeal({
    required String mealId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      final meals = await _getAllStoredMeals();
      final index = meals.indexWhere((m) => m.id == mealId);
      
      if (index != -1) {
        final meal = meals[index];
        final updatedMeal = meal.copyWith(
          name: name,
          description: description,
          price: price,
          category: category,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
        );
        
        meals[index] = updatedMeal;
        await _saveAllMeals(meals);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating meal: $e');
      return false;
    }
  }

  // Delete meal
  Future<bool> deleteMeal(String mealId) async {
    try {
      final meals = await _getAllStoredMeals();
      meals.removeWhere((m) => m.id == mealId);
      await _saveAllMeals(meals);
      return true;
    } catch (e) {
      print('Error deleting meal: $e');
      return false;
    }
  }

  // Private helper methods
  Future<List<Restaurant>> _getAllStoredRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final restaurantsJson = prefs.getString(_restaurantsKey);
    if (restaurantsJson != null) {
      final List<dynamic> restaurantsList = json.decode(restaurantsJson);
      return restaurantsList.map((data) => Restaurant.fromMap(data)).toList();
    }
    return [];
  }

  Future<void> _saveAllRestaurants(List<Restaurant> restaurants) async {
    final prefs = await SharedPreferences.getInstance();
    final restaurantsJson = json.encode(restaurants.map((r) => r.toMap()).toList());
    await prefs.setString(_restaurantsKey, restaurantsJson);
  }

  Future<void> _saveRestaurant(Restaurant restaurant) async {
    final restaurants = await _getAllStoredRestaurants();
    final index = restaurants.indexWhere((r) => r.id == restaurant.id);
    if (index != -1) {
      restaurants[index] = restaurant;
    } else {
      restaurants.add(restaurant);
    }
    await _saveAllRestaurants(restaurants);
  }

  Future<List<Meal>> _getAllStoredMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = prefs.getString(_mealsKey);
    if (mealsJson != null) {
      final List<dynamic> mealsList = json.decode(mealsJson);
      return mealsList.map((data) => Meal.fromMap(data)).toList();
    }
    return [];
  }

  Future<void> _saveAllMeals(List<Meal> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = json.encode(meals.map((m) => m.toMap()).toList());
    await prefs.setString(_mealsKey, mealsJson);
  }

  Future<void> _saveMeal(Meal meal) async {
    final meals = await _getAllStoredMeals();
    final index = meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      meals[index] = meal;
    } else {
      meals.add(meal);
    }
    await _saveAllMeals(meals);
  }

  // Initialize sample data
  Future<void> _initializeSampleRestaurants() async {
    final sampleRestaurants = [
      Restaurant(
        id: 'sample_1',
        name: 'Buea Grill House',
        cuisine: 'Cameroonian',
        address: 'Molyko, Buea',
        description: 'Authentic Cameroonian cuisine with a modern twist',
        imageUrl: 'https://via.placeholder.com/300x200?text=Buea+Grill',
        rating: 4.5,
        totalRatings: 150,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Restaurant(
        id: 'sample_2',
        name: 'Pizza Palace',
        cuisine: 'Italian',
        address: 'Mile 17, Buea',
        description: 'Delicious wood-fired pizzas and pasta',
        imageUrl: 'https://via.placeholder.com/300x200?text=Pizza+Palace',
        rating: 4.2,
        totalRatings: 89,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Restaurant(
        id: 'sample_3',
        name: 'Spice Garden',
        cuisine: 'Indian',
        address: 'Government Estate, Buea',
        description: 'Aromatic Indian spices and traditional recipes',
        imageUrl: 'https://via.placeholder.com/300x200?text=Spice+Garden',
        rating: 4.7,
        totalRatings: 203,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    await _saveAllRestaurants(sampleRestaurants);
  }

  Future<void> _initializeSampleMeals(String restaurantId) async {
    final sampleMeals = [
      Meal(
        id: '${restaurantId}_meal_1',
        restaurantId: restaurantId,
        name: 'Grilled Chicken',
        description: 'Tender grilled chicken with local spices',
        price: 2500.0,
        category: 'Main Course',
        imageUrl: 'https://via.placeholder.com/300x200?text=Grilled+Chicken',
        isAvailable: true,
        createdAt: DateTime.now(),
      ),
      Meal(
        id: '${restaurantId}_meal_2',
        restaurantId: restaurantId,
        name: 'Jollof Rice',
        description: 'Spicy West African rice dish',
        price: 1500.0,
        category: 'Main Course',
        imageUrl: 'https://via.placeholder.com/300x200?text=Jollof+Rice',
        isAvailable: true,
        createdAt: DateTime.now(),
      ),
      Meal(
        id: '${restaurantId}_meal_3',
        restaurantId: restaurantId,
        name: 'Fresh Fruit Juice',
        description: 'Freshly squeezed local fruit juice',
        price: 500.0,
        category: 'Beverages',
        imageUrl: 'https://via.placeholder.com/300x200?text=Fruit+Juice',
        isAvailable: true,
        createdAt: DateTime.now(),
      ),
    ];

    final existingMeals = await _getAllStoredMeals();
    existingMeals.addAll(sampleMeals);
    await _saveAllMeals(existingMeals);
  }
}