// lib/screens/restaurant/restaurant_dashboard.dart
import 'package:flutter/material.dart';
import 'package:moptaste/models/restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';
import '../../models/order.dart'; // Import Order model
import '../../models/meal.dart'; // Import Meal model

class RestaurantDashboard extends StatefulWidget {
  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> with SingleTickerProviderStateMixin {
  String userName = '';
  String restaurantId = 'rest1'; // Dummy restaurant ID for this dashboard (e.g., The Spicy Spoon)
  List<Order> _incomingOrders = [];
  List<Meal> _restaurantMenu = []; // This will hold the menu items for management

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _fetchRestaurantData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Restaurant Owner';
      // In a real app, restaurantId would come from user login data
      // For now, we'll assume this dashboard is for 'The Spicy Spoon' (rest1)
    });
  }

  _fetchRestaurantData() {
    setState(() {
      // 1. Simulate fetching incoming orders for this restaurant
      // Filter orders by restaurant name which corresponds to our dummy ID 'rest1'
      _incomingOrders = Order.dummyOrders.where((order) =>
      order.pickupLocation == 'The Spicy Spoon' && // Assuming 'The Spicy Spoon' is rest1
          (order.status == OrderStatus.pending || order.status == OrderStatus.preparing || order.status == OrderStatus.readyForPickup)
      ).toList();

      // 2. Find the specific restaurant object from dummy data
      final Restaurant? currentRestaurant = Restaurant.dummyRestaurants.firstWhere(
            (rest) => rest.id == restaurantId,
        orElse: () => Restaurant(
            id: 'temp', name: 'Unknown Restaurant', imageUrl: '', cuisine: '', rating: 0, address: '', description: '', menu: []
        ),
      );

      // 3. Initialize _restaurantMenu with the actual menu items of the found restaurant.
      // Use List.from to create a mutable copy from the constant menu list.
      _restaurantMenu = List.from(currentRestaurant?.menu ?? []);

      // 4. Add dummy recipes for management purposes, ensuring no duplicates
      for (var recipe in Meal.dummyRecipes) {
        // Only add if an item with the same ID isn't already in the menu
        if (!_restaurantMenu.any((meal) => meal.id == recipe.id)) {
          _restaurantMenu.add(recipe);
        }
      }
    });
  }

  _updateOrderStatus(Order order, OrderStatus newStatus) {
    setState(() {
      order.status = newStatus;
      if (newStatus == OrderStatus.readyForPickup || newStatus == OrderStatus.delivered) {
        // In a real app, this would typically move to an 'order history' list
        _incomingOrders.removeWhere((o) => o.id == order.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.id} status updated to ${newStatus.toString().split('.').last}!'),
        backgroundColor: AppTheme.primaryOrange,
      ),
    );
  }

  _addMenuItem(Meal newItem) {
    setState(() {
      _restaurantMenu.add(newItem);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newItem.name} added to menu!')),
    );
  }

  _editMenuItem(Meal oldItem, Meal newItem) {
    setState(() {
      final index = _restaurantMenu.indexOf(oldItem);
      if (index != -1) {
        _restaurantMenu[index] = newItem;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newItem.name} updated!')),
    );
  }

  _deleteMenuItem(Meal item) {
    setState(() {
      _restaurantMenu.removeWhere((menuItem) => menuItem.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} removed from menu!')),
    );
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
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Dashboard - ${userName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Incoming Orders', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Menu Management', icon: Icon(Icons.restaurant_menu)),
          ],
          labelColor: AppTheme.neutralWhite,
          unselectedLabelColor: AppTheme.neutralWhite.withOpacity(0.7),
          indicatorColor: AppTheme.primaryYellow,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Incoming Orders Tab
          _buildIncomingOrdersTab(),
          // Menu Management Tab
          _buildMenuManagementTab(),
        ],
      ),
    );
  }

  Widget _buildIncomingOrdersTab() {
    if (_incomingOrders.isEmpty) {
      return Center(
        child: Text(
          'No incoming orders at the moment.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _incomingOrders.length,
      itemBuilder: (context, index) {
        final order = _incomingOrders[index];
        return RestaurantOrderCard(
          order: order,
          onUpdateStatus: _updateOrderStatus,
        );
      },
    );
  }

  Widget _buildMenuManagementTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddEditMealDialog(context);
              },
              icon: Icon(Icons.add_circle),
              label: Text('Add New Menu Item', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: _restaurantMenu.isEmpty
              ? Center(
            child: Text(
              'No menu items added yet.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _restaurantMenu.length,
            itemBuilder: (context, index) {
              final meal = _restaurantMenu[index];
              return MenuListItem(
                meal: meal,
                onEdit: (updatedMeal) => _showAddEditMealDialog(context, mealToEdit: meal, currentMeal: updatedMeal),
                onDelete: _deleteMenuItem,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEditMealDialog(BuildContext context, {Meal? mealToEdit, Meal? currentMeal}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddEditMealDialog(
          mealToEdit: mealToEdit,
          onSave: (newMeal) {
            if (mealToEdit == null) {
              _addMenuItem(newMeal);
            } else {
              _editMenuItem(currentMeal ?? mealToEdit, newMeal);
            }
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }
}

class RestaurantOrderCard extends StatelessWidget {
  final Order order;
  final Function(Order, OrderStatus) onUpdateStatus;

  const RestaurantOrderCard({
    Key? key,
    required this.order,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusIcon = Icons.access_time;
        statusColor = AppTheme.accentRed;
        statusText = 'New Order';
        break;
      case OrderStatus.preparing:
        statusIcon = Icons.hourglass_bottom;
        statusColor = AppTheme.primaryYellow;
        statusText = 'Preparing';
        break;
      case OrderStatus.readyForPickup:
        statusIcon = Icons.delivery_dining;
        statusColor = Colors.green;
        statusText = 'Ready for Pickup';
        break;
      case OrderStatus.onTheWay: // Should not appear here often, as it's for agent
        statusIcon = Icons.local_shipping;
        statusColor = AppTheme.lightGrey;
        statusText = 'On the Way (Agent)';
        break;
      case OrderStatus.delivered: // Should not appear here often
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Delivered';
        break;
      case OrderStatus.cancelled:
        statusIcon = Icons.cancel;
        statusColor = AppTheme.darkGrey;
        statusText = 'Cancelled';
        break;
    }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 18, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'For: ${order.clientName} (Phone: ${order.clientId})', // Dummy phone for client ID
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neutralBlack),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: AppTheme.accentRed),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Deliver to: ${order.clientAddress}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Items:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...order.items.map((item) => Text(
              '- ${item.name} x${item.quantity} (FCFA ${item.unitPrice.toStringAsFixed(0)})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
            )).toList(),
            SizedBox(height: 10),
            Divider(color: AppTheme.lightGrey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Order Value:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'FCFA ${order.totalOrderPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (order.status == OrderStatus.pending)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onUpdateStatus(order, OrderStatus.preparing),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                      child: Text('Start Preparing'),
                    ),
                  ),
                if (order.status == OrderStatus.pending) SizedBox(width: 10),
                if (order.status == OrderStatus.pending || order.status == OrderStatus.preparing)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onUpdateStatus(order, OrderStatus.readyForPickup),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                      child: Text('Ready for Pickup'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuListItem extends StatelessWidget {
  final Meal meal;
  final Function(Meal) onEdit;
  final Function(Meal) onDelete;

  const MenuListItem({
    Key? key,
    required this.meal,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
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
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 60,
                  width: 60,
                  color: AppTheme.lightGrey,
                  child: Center(
                    child: Icon(meal.isMeal ? Icons.fastfood : Icons.menu_book, color: AppTheme.darkGrey),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neutralBlack, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    meal.isMeal ? 'FCFA ${meal.price.toStringAsFixed(0)}' : 'Recipe',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: meal.isMeal ? AppTheme.accentRed : AppTheme.primaryYellow),
                  ),
                  Text(
                    meal.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppTheme.primaryOrange),
                  onPressed: () => onEdit(meal),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppTheme.accentRed),
                  onPressed: () => onDelete(meal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditMealDialog extends StatefulWidget {
  final Meal? mealToEdit;
  final Function(Meal) onSave;

  const AddEditMealDialog({Key? key, this.mealToEdit, required this.onSave}) : super(key: key);

  @override
  _AddEditMealDialogState createState() => _AddEditMealDialogState();
}

class _AddEditMealDialogState extends State<AddEditMealDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  bool _isMeal = true;
  List<TextEditingController> _ingredientControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mealToEdit?.name ?? '');
    _descriptionController = TextEditingController(text: widget.mealToEdit?.description ?? '');
    _priceController = TextEditingController(text: widget.mealToEdit?.isMeal == true ? widget.mealToEdit?.price.toString() : '');
    _imageUrlController = TextEditingController(text: widget.mealToEdit?.imageUrl ?? '');
    _isMeal = widget.mealToEdit?.isMeal ?? true;

    if (widget.mealToEdit != null && !widget.mealToEdit!.isMeal && widget.mealToEdit!.ingredients.isNotEmpty) {
      for (var ingredient in widget.mealToEdit!.ingredients) {
        _ingredientControllers.add(TextEditingController(text: ingredient));
      }
    } else {
      _ingredientControllers.add(TextEditingController()); // Start with one empty ingredient field
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mealToEdit == null ? 'Add New Menu Item' : 'Edit Menu Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Description cannot be empty' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) => value!.isEmpty ? 'Image URL cannot be empty' : null,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Is a prepared meal?'),
                  Switch(
                    value: _isMeal,
                    onChanged: (bool value) {
                      setState(() {
                        _isMeal = value;
                      });
                    },
                    activeColor: AppTheme.primaryOrange,
                  ),
                ],
              ),
              if (_isMeal)
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price (FCFA)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Price cannot be empty';
                    if (double.tryParse(value) == null) return 'Invalid price';
                    return null;
                  },
                )
              else ...[
                SizedBox(height: 10),
                Text('Ingredients:', style: Theme.of(context).textTheme.titleMedium),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _ingredientControllers.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ingredientControllers[index],
                            decoration: InputDecoration(labelText: 'Ingredient ${index + 1}'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: AppTheme.accentRed),
                          onPressed: () => _removeIngredientField(index),
                        ),
                      ],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addIngredientField,
                    icon: Icon(Icons.add, color: AppTheme.primaryOrange),
                    label: Text('Add Ingredient'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final List<String> ingredients = _isMeal ? [] : _ingredientControllers.map((c) => c.text).where((text) => text.isNotEmpty).toList();
              final newMeal = Meal(
                id: widget.mealToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
                name: _nameController.text,
                description: _descriptionController.text,
                price: _isMeal ? double.parse(_priceController.text) : 0.0,
                imageUrl: _imageUrlController.text,
                isMeal: _isMeal,
                ingredients: ingredients,
              );
              widget.onSave(newMeal);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}