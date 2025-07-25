// lib/screens/client/restaurant_menu_screen.dart
import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../models/meal.dart';
import '../../utils/theme.dart';

class RestaurantMenuScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantMenuScreen({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        backgroundColor: AppTheme.primaryOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                restaurant.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppTheme.lightGrey,
                  child: Center(
                    child: Icon(Icons.restaurant, size: 80, color: AppTheme.darkGrey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              restaurant.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralBlack,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star_rounded, color: AppTheme.primaryYellow, size: 20),
                SizedBox(width: 4),
                Text(
                  '${restaurant.rating.toStringAsFixed(1)} • ${restaurant.cuisine} • ${restaurant.address}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              restaurant.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
            ),
            SizedBox(height: 24),
            Text(
              'Full Menu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
            Divider(color: AppTheme.lightGrey, thickness: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: restaurant.menu.length,
              itemBuilder: (context, index) {
                final meal = restaurant.menu[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: MealMenuItem(
                    meal: meal,
                    onOrder: (orderedMeal) {
                      _showOrderConfirmationDialog(context, orderedMeal);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, Meal meal) {
    if (!meal.isMeal) {
      // If it's a recipe, we'll handle it separately with the new RecipeOrderFormDialog
      // This button shouldn't really be visible for recipes if we separate concerns
      // but as a fallback, we'll just show a simple message for now.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please use the "Order Ingredients" button for recipes.')),
      );
      return;
    }

    int quantity = 1; // Initial quantity

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog content
          builder: (context, setState) {
            double totalPrice = meal.price * quantity;

            return AlertDialog(
              title: Text('Confirm Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You are about to order:'),
                  SizedBox(height: 8),
                  Text(
                    '${meal.name}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryOrange),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Price per item: FCFA ${meal.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 14, color: AppTheme.darkGrey),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: AppTheme.accentRed),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: AppTheme.primaryYellow),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Total Price: FCFA ${totalPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentRed,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Proceed with order?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // In a real app, this would send the order to a backend
                    Navigator.pop(dialogContext); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ordered $quantity ${meal.name}(s) successfully!')),
                    );
                    // Optionally navigate to an order tracking screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                  ),
                  child: Text('Order Now'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// MealMenuItem remains the same
class MealMenuItem extends StatelessWidget {
  final Meal meal;
  final Function(Meal) onOrder;

  const MealMenuItem({Key? key, required this.meal, required this.onOrder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                meal.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  width: 80,
                  color: AppTheme.lightGrey,
                  child: Center(
                    child: Icon(meal.isMeal ? Icons.fastfood : Icons.menu_book, size: 40, color: AppTheme.darkGrey),
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
                    meal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    meal.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (meal.isMeal)
                    Text(
                      'FCFA ${meal.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentRed,
                      ),
                    ),
                  if (!meal.isMeal && meal.ingredients.isNotEmpty)
                    Text(
                      'Ingredients: ${meal.ingredients.take(2).join(', ')}${meal.ingredients.length > 2 ? '...' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => onOrder(meal),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: AppTheme.neutralWhite,
                minimumSize: Size(80, 35),
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text('Order', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}