// lib/screens/client/ingredient_order_screen.dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class IngredientOrderScreen extends StatefulWidget {
  final List<String> ingredients;

  const IngredientOrderScreen({Key? key, required this.ingredients}) : super(key: key);

  @override
  _IngredientOrderScreenState createState() => _IngredientOrderScreenState();
}

class _IngredientOrderScreenState extends State<IngredientOrderScreen> {
  // Dummy list of available delivery agents
  final List<Map<String, dynamic>> _deliveryAgents = [
    {
      'id': 'agent1',
      'name': 'David Eposi',
      'rating': 4.7,
      'eta': '25-35 min',
      'fee': 500,
      'imageUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'id': 'agent2',
      'name': 'Grace Ngum',
      'rating': 4.9,
      'eta': '20-30 min',
      'fee': 600,
      'imageUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'id': 'agent3',
      'name': 'Samwel Njie',
      'rating': 4.3,
      'eta': '30-45 min',
      'fee': 450,
      'imageUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
  ];

  String? _selectedAgentId;
  bool _isOrdering = false;

  void _showOrderConfirmation() {
    if (_selectedAgentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a delivery agent.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final selectedAgent = _deliveryAgents.firstWhere((agent) => agent['id'] == _selectedAgentId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Ingredient Order', style: TextStyle(color: AppTheme.primaryOrange)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to order these ingredients:', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 10),
              ...widget.ingredients.map((ing) => Text('- $ing', style: Theme.of(context).textTheme.bodyMedium)).toList(),
              SizedBox(height: 15),
              Text('Selected Delivery Agent: ${selectedAgent['name']}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text('Delivery Fee: FCFA ${selectedAgent['fee'].toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 20),
              Text('This is a simulated order. Your request will be sent to the delivery agent.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text('Place Order'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _placeIngredientOrder();
              },
            ),
          ],
        );
      },
    );
  }

  void _placeIngredientOrder() async {
    setState(() {
      _isOrdering = true;
    });

    await Future.delayed(Duration(seconds: 3)); // Simulate order placement

    setState(() {
      _isOrdering = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ingredient order placed and sent to delivery agent!'),
        backgroundColor: AppTheme.primaryOrange,
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.popUntil(context, ModalRoute.withName('/client-dashboard')); // Go back to client dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Ingredients'),
      ),
      body: _isOrdering
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange)),
            SizedBox(height: 20),
            Text('Sending order to delivery agent...', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredients for your recipe:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.ingredients.isEmpty
                      ? [Text('No ingredients specified for this recipe.', style: Theme.of(context).textTheme.bodyLarge)]
                      : widget.ingredients
                      .map(
                        (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.fastfood_outlined, color: AppTheme.primaryYellow, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Select a Delivery Agent:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _deliveryAgents.length,
              itemBuilder: (context, index) {
                final agent = _deliveryAgents[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: _selectedAgentId == agent['id'] ? 6 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: _selectedAgentId == agent['id'] ? AppTheme.accentRed : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: agent['id'],
                    groupValue: _selectedAgentId,
                    onChanged: (value) {
                      setState(() {
                        _selectedAgentId = value;
                      });
                    },
                    activeColor: AppTheme.primaryOrange,
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(agent['imageUrl']),
                          radius: 25,
                          onBackgroundImageError: (exception, stackTrace) {
                            // Fallback to a default icon if image fails to load
                            print('Error loading image for agent: ${agent['name']}');
                          },
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent['name'],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neutralBlack, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star_rounded, color: AppTheme.primaryYellow, size: 18),
                                  Text('${agent['rating']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey)),
                                  SizedBox(width: 8),
                                  Icon(Icons.access_time, color: AppTheme.darkGrey, size: 18),
                                  Text(agent['eta'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Delivery Fee: FCFA ${agent['fee'].toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showOrderConfirmation,
                child: Text('Confirm Order with Agent', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}