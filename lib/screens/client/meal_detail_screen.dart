// lib/screens/client/meal_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/meal.dart';
import '../../utils/theme.dart';
import 'order_form_screen.dart'; // Will create this next
import 'recipe_screen.dart';   // Will create this next

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              meal.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: AppTheme.lightGrey,
                child: Center(
                  child: Icon(Icons.broken_image, color: AppTheme.darkGrey, size: 80),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (meal.isMeal)
                    Text(
                      'Price: FCFA ${meal.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
                    )
                  else
                    Text(
                      'Type: Recipe',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryYellow, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neutralBlack, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    meal.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
                  ),
                  if (!meal.isMeal && meal.ingredients.isNotEmpty) ...[
                    SizedBox(height: 24),
                    Text(
                      'Key Ingredients:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neutralBlack, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: meal.ingredients.map((ingredient) => Chip(
                        label: Text(ingredient, style: TextStyle(color: AppTheme.neutralBlack)),
                        backgroundColor: AppTheme.lightGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      )).toList(),
                    ),
                  ],
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (meal.isMeal) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderFormScreen(meal: meal),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeScreen(recipe: meal),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: meal.isMeal ? AppTheme.primaryOrange : AppTheme.primaryYellow,
                        foregroundColor: AppTheme.neutralWhite,
                      ),
                      child: Text(
                        meal.isMeal ? 'Order Now' : 'View Recipe / Order Ingredients',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}