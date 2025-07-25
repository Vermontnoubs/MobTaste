// lib/models/restaurant.dart
import 'package:flutter/material.dart'; // Just for dummy placeholder icon if needed
import 'meal.dart'; // Import the Meal model

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String cuisine;
  final double rating;
  final String address;
  final String description;
  final List<Meal> menu; // List of meals/recipes offered by this restaurant

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisine,
    required this.rating,
    required this.address,
    required this.description,
    required this.menu,
  });

  // Dummy static list of restaurants
  static List<Restaurant> dummyRestaurants = [
    Restaurant(
      id: 'rest1',
      name: 'The Spicy Spoon',
      imageUrl: 'https://cdn.pixabay.com/photo/2017/01/22/10/37/restaurant-2002670_960_720.jpg',
      cuisine: 'African & Continental',
      rating: 4.5,
      address: 'Buea Town, Great Soppo, Buea',
      description: 'A cozy spot for authentic African and delicious continental dishes.',
      menu: [
        Meal(
          id: 'meal101',
          name: 'Chicken Biryani',
          description: 'A flavorful and aromatic rice dish with marinated chicken.',
          price: 5000,
          imageUrl: 'https://cdn.pixabay.com/photo/2018/06/18/16/05/chicken-biryani-3482357_960_720.jpg',
          isMeal: true,
          ingredients: [],
        ),
        Meal(
          id: 'meal102',
          name: 'Jollof Rice with Grilled Fish',
          description: 'Smoky Jollof rice served with perfectly grilled fish and plantains.',
          price: 4500,
          imageUrl: 'https://cdn.pixabay.com/photo/2018/08/07/11/48/jollof-rice-3590510_960_720.jpg',
          isMeal: true,
          ingredients: [],
        ),
        Meal(
          id: 'recipe101',
          name: 'Egusi Soup Recipe',
          description: 'A traditional West African soup made with melon seeds, vegetables, and meat.',
          price: 0.0, // Recipes have no direct price
          imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/ea/Egusi_Soup_and_Pounded_Yam.jpg',
          isMeal: false,
          ingredients: [
            'Ground Egusi (melon seeds)',
            'Spinach or Bitter leaf',
            'Palm oil',
            'Smoked fish',
            'Beef or Goat meat',
            'Crayfish',
            'Onions, Peppers, Tomatoes',
            'Seasoning cubes, Salt'
          ],
        ),
      ],
    ),
    Restaurant(
      id: 'rest2',
      name: 'Pizzeria Bella',
      imageUrl: 'https://cdn.pixabay.com/photo/2016/03/05/19/02/pizza-1238965_960_720.jpg',
      cuisine: 'Italian',
      rating: 4.8,
      address: 'Molyko, Buea',
      description: 'Authentic Italian pizzas and pastas made with fresh ingredients.',
      menu: [
        Meal(
          id: 'meal201',
          name: 'Margherita Pizza',
          description: 'Classic pizza with tomato, mozzarella, and fresh basil.',
          price: 6000,
          imageUrl: 'https://cdn.pixabay.com/photo/2017/02/09/00/29/pizza-2051648_960_720.jpg',
          isMeal: true,
          ingredients: [],
        ),
        Meal(
          id: 'meal202',
          name: 'Spaghetti Bolognese',
          description: 'Rich meat sauce served over spaghetti, a timeless Italian favorite.',
          price: 5500,
          imageUrl: 'https://cdn.pixabay.com/photo/2016/08/11/08/04/spaghetti-1584029_960_720.jpg',
          isMeal: true,
          ingredients: [],
        ),
      ],
    ),
  ];
}