// lib/screens/client/recipe_screen.dart
import 'package:flutter/material.dart';
import '../../models/meal.dart'; // Using Meal model for recipe details
import '../../utils/theme.dart';
import 'ingredient_order_screen.dart'; // Will create this next

class RecipeScreen extends StatelessWidget {
  final Meal recipe; // Using Meal model to represent a recipe

  const RecipeScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy instructions for the recipe
    final String dummyInstructions = """
    1.  Gather all ingredients.
    2.  Prepare your workstation.
    3.  Follow the specific steps for each component of the recipe.
    4.  Cook thoroughly and ensure food safety.
    5.  Serve and enjoy!
    """;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              recipe.imageUrl,
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
                    recipe.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Ingredients:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.neutralBlack, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (recipe.ingredients.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.ingredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20, color: AppTheme.primaryYellow),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    )
                  else
                    Text('No specific ingredients listed for this recipe.'),
                  SizedBox(height: 24),
                  Text(
                    'Instructions:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.neutralBlack, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    dummyInstructions,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to ingredient order screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IngredientOrderScreen(ingredients: recipe.ingredients),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange, // Use primary orange for ordering ingredients
                        foregroundColor: AppTheme.neutralWhite,
                      ),
                      child: Text(
                        'Order These Ingredients',
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