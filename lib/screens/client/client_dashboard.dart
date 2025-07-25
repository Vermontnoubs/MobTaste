// lib/screens/client/client_dashboard.dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/meal.dart';
import '../../models/restaurant.dart';
import '../../models/user.dart';
import '../../controllers/auth_service.dart';
import '../../controllers/restaurant_service.dart';
import 'restaurant_menu_screen.dart';

class ClientDashboard extends StatefulWidget {
  @override
  _ClientDashboardState createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _restaurantService = RestaurantService();
  
  AppUser? currentUser;
  late TabController _tabController;
  final TextEditingController _restaurantSearchController = TextEditingController();
  final TextEditingController _recipeSearchController = TextEditingController();
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<Meal> _filteredRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadRestaurants();
    _filteredRecipes = Meal.dummyRecipes; // Initialize with all recipes

    _restaurantSearchController.addListener(_filterRestaurants);
    _recipeSearchController.addListener(_filterRecipes);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _restaurantSearchController.dispose();
    _recipeSearchController.dispose();
    super.dispose();
  }

  _loadUserData() async {
    try {
      final user = await _authService.getCurrentAppUser();
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  _loadRestaurants() async {
    try {
      final restaurants = await _restaurantService.getAllRestaurants();
      setState(() {
        _allRestaurants = restaurants;
        _filteredRestaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading restaurants: $e');
      setState(() {
        _allRestaurants = Restaurant.dummyRestaurants; // Fallback to dummy data
        _filteredRestaurants = Restaurant.dummyRestaurants;
        _isLoading = false;
      });
    }
  }

  void _filterRestaurants() {
    final query = _restaurantSearchController.text.toLowerCase();
    setState(() {
      _filteredRestaurants = _allRestaurants.where((restaurant) {
        return restaurant.name.toLowerCase().contains(query) ||
            restaurant.cuisine.toLowerCase().contains(query) ||
            restaurant.address.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _filterRecipes() {
    final query = _recipeSearchController.text.toLowerCase();
    setState(() {
      _filteredRecipes = Meal.dummyRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query) ||
            recipe.description.toLowerCase().contains(query) ||
            recipe.ingredients.any((ingredient) => ingredient.toLowerCase().contains(query));
      }).toList();
    });
  }

  _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser?.name ?? 'Client'}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Restaurants', icon: Icon(Icons.restaurant)),
            Tab(text: 'Recipes', icon: Icon(Icons.menu_book)),
          ],
          labelColor: AppTheme.neutralWhite,
          unselectedLabelColor: AppTheme.neutralWhite.withOpacity(0.7),
          indicatorColor: AppTheme.primaryYellow,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Restaurants Tab
          _buildRestaurantsTab(),
          // Recipes Tab
          _buildRecipesTab(),
        ],
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _restaurantSearchController,
            decoration: InputDecoration(
              hintText: 'Search restaurants...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryOrange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.lightGrey.withOpacity(0.3),
            ),
          ),
        ),
        Expanded(
          child: _filteredRestaurants.isEmpty
              ? Center(
            child: Text(
              'No restaurants found matching your search.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _filteredRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = _filteredRestaurants[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/restaurant-menu',
                    arguments: restaurant,
                  );
                },
                child: RestaurantCard(
                  restaurant: restaurant,
                  onOrder: (meal) { /* This callback is not actively used here anymore for direct orders */ },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _recipeSearchController,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryOrange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.lightGrey.withOpacity(0.3),
            ),
          ),
        ),
        Expanded(
          child: _filteredRecipes.isEmpty
              ? Center(
            child: Text(
              'No recipes found matching your search.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _filteredRecipes[index];
              return RecipeCard(
                recipe: recipe,
                onOrderIngredients: (recipe) {
                  _showRecipeOrderFormDialog(context, recipe); // Call new dialog
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // NEW METHOD: Order form for recipes (ingredients)
  void _showRecipeOrderFormDialog(BuildContext context, Meal recipe) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Order Ingredients for ${recipe.name}'),
          content: SingleChildScrollView( // Use SingleChildScrollView for long ingredient lists
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm order for the following ingredients:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 10),
                // Display ingredients with bullet points
                if (recipe.ingredients.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.ingredients
                        .map((ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '• $ingredient',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
                      ),
                    ))
                        .toList(),
                  )
                else
                  Text(
                    'No specific ingredients listed for this recipe.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                SizedBox(height: 20),
                Text(
                  'Estimated Cost: FCFA ${recipe.price.toStringAsFixed(0)}', // Using recipe price as estimated cost
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentRed,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Proceed with ordering these ingredients?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Here you would send the ingredient order to your backend
                Navigator.pop(dialogContext); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ingredients for ${recipe.name} ordered successfully!')),
                );
                // Optionally navigate to an order tracking screen or confirm order
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
              ),
              child: Text('Confirm Order'),
            ),
          ],
        );
      },
    );
  }
}

// RestaurantCard remains the same (without direct order button for meals)
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final Function(Meal) onOrder; // This callback is still required by the constructor

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              restaurant.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: AppTheme.lightGrey,
                child: Center(
                  child: Icon(Icons.restaurant, size: 50, color: AppTheme.darkGrey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '${restaurant.cuisine} • ${restaurant.address}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppTheme.primaryYellow, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '${restaurant.rating.toStringAsFixed(1)} Rating',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Popular Dishes:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Only show a preview of popular dishes here
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: restaurant.menu.where((meal) => meal.isMeal).take(3).length, // Show up to 3 meals
                  itemBuilder: (context, idx) {
                    final meal = restaurant.menu.where((meal) => meal.isMeal).elementAt(idx);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '- ${meal.name} (FCFA ${meal.price.toStringAsFixed(0)})',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tap to view full menu',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// RecipeCard is updated to call the new _showRecipeOrderFormDialog
class RecipeCard extends StatelessWidget {
  final Meal recipe;
  final Function(Meal) onOrderIngredients;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onOrderIngredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    recipe.imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: AppTheme.lightGrey,
                      child: Center(
                        child: Icon(Icons.menu_book, size: 40, color: AppTheme.darkGrey),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              'Key Ingredients:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: recipe.ingredients
                  .map((ingredient) => Chip(
                label: Text(ingredient),
                backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                labelStyle: TextStyle(color: AppTheme.neutralBlack),
              ))
                  .toList(),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onOrderIngredients(recipe), // This calls the new dialog
                icon: Icon(Icons.shopping_cart),
                label: Text('Order Ingredients'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.neutralWhite,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}