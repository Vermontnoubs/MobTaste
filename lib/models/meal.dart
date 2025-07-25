// lib/models/meal.dart
import 'package:flutter/material.dart'; // Only if using Icons or similar in the model itself (not strictly needed for basic model)

class Meal {
  final String id;
  final String name;
  final String description;
  final double price; // Price for prepared meals, 0 for recipes
  final String imageUrl;
  final bool isMeal; // true if it's a prepared meal, false if it's a recipe
  final List<String> ingredients; // Only for recipes

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isMeal = true, // Default to true for convenience
    this.ingredients = const [], // Default to empty list
  });

  // Dummy static list of recipes for the recipe screen and ingredient ordering
  static List<Meal> dummyRecipes = [
    Meal(
      id: 'recipe1',
      name: 'Ndole Recipe',
      description: 'A popular Cameroonian dish made with bitter leaves, peanuts, and meat or fish.',
      price: 0.0,
      imageUrl: 'https://img-global.cpcdn.com/recipes/5eb9192419f4a56d/680x482cq70/ndole-recipe-main-photo.webp',
      isMeal: false,
      ingredients: [
        'Fresh Bitter Leaves',
        'Roasted peanuts (ground)',
        'Beef or Smoked Fish',
        'Palm oil',
        'Onions',
        'Garlic',
        'Ginger',
        'Hot Pepper (optional)',
        'Crayfish (ground)',
        'Salt and Seasoning cubes',
      ],
    ),
    Meal(
      id: 'recipe2',
      name: 'Achombo Recipe',
      description: 'A traditional dish from the Northwest region of Cameroon, typically made with cocoyams, huckleberry, and meat.',
      price: 0.0,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/23/Achu_and_yellow_soup.jpg',
      isMeal: false,
      ingredients: [
        'Cocoyams',
        'Huckleberry leaves (achu-soup leaves)',
        'Smoked fish or Beef',
        'Palm oil (red oil)',
        'Achu spices (can be a mix of traditional spices)',
        'Potash (kanda/akanwu) - very little for texture',
        'Salt',
        'Pepper',
      ],
    ),
    Meal(
      id: 'recipe3',
      name: 'Ekwang Recipe',
      description: 'A delicious traditional dish from the Bakweri tribe, made from grated cocoyams wrapped in cocoyam leaves.',
      price: 0.0,
      imageUrl: 'https://guardian.ng/wp-content/uploads/2016/09/Ekwang.jpg',
      isMeal: false,
      ingredients: [
        'Cocoyams (grated)',
        'Cocoyam leaves (green)',
        'Smoked fish',
        'Meat (beef or goat)',
        'Palm oil',
        'Crayfish (ground)',
        'Onions',
        'Hot pepper (optional)',
        'Salt and seasoning cubes',
      ],
    ),
  ];
}