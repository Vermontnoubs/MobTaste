// lib/screens/client/order_form_screen.dart
import 'package:flutter/material.dart';
import '../../models/meal.dart';
import '../../utils/theme.dart';

class OrderFormScreen extends StatefulWidget {
  final Meal meal;

  const OrderFormScreen({Key? key, required this.meal}) : super(key: key);

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  int _quantity = 1;
  bool _isProcessingOrder = false;

  double get _totalPrice => widget.meal.price * _quantity;

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Order Confirmation', style: TextStyle(color: AppTheme.primaryOrange)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to order:', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 10),
              Text('Meal: ${widget.meal.name}', style: Theme.of(context).textTheme.bodyLarge),
              Text('Quantity: $_quantity', style: Theme.of(context).textTheme.bodyLarge),
              Text('Total: FCFA ${_totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('This is a simulated payment. Your order will be placed upon confirmation.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            ElevatedButton(
              child: Text('Confirm Order'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                _placeOrder(); // Proceed with placing the order
              },
            ),
          ],
        );
      },
    );
  }

  void _placeOrder() async {
    setState(() {
      _isProcessingOrder = true;
    });

    // Simulate payment and order placement
    await Future.delayed(Duration(seconds: 3)); // Simulate network request

    setState(() {
      _isProcessingOrder = false;
    });

    // Show success message and navigate back to dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order for "${widget.meal.name}" placed successfully!'),
        backgroundColor: AppTheme.primaryOrange,
        duration: Duration(seconds: 3),
      ),
    );

    // Optionally navigate back to the client dashboard or order history
    Navigator.popUntil(context, ModalRoute.withName('/client-dashboard')); // Go back to client dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${widget.meal.name}'),
      ),
      body: _isProcessingOrder
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange)),
            SizedBox(height: 20),
            Text('Processing your order...', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.meal.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: AppTheme.lightGrey,
                    child: Center(child: Icon(Icons.broken_image, color: AppTheme.darkGrey, size: 60)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.meal.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.meal.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
            ),
            SizedBox(height: 20),
            Divider(color: AppTheme.lightGrey),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unit Price:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.neutralBlack),
                ),
                Text(
                  'FCFA ${widget.meal.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.neutralBlack),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: AppTheme.primaryOrange),
                      onPressed: () {
                        setState(() {
                          if (_quantity > 1) _quantity--;
                        });
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.neutralBlack),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: AppTheme.primaryOrange),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(color: AppTheme.lightGrey),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Price:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.neutralBlack, fontWeight: FontWeight.bold),
                ),
                Text(
                  'FCFA ${_totalPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showOrderConfirmation,
                child: Text('Proceed to Payment (Simulated)', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}