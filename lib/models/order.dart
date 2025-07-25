// lib/models/order.dart
import 'package:flutter/material.dart'; // For IconData, if used directly in model for status icons
import 'package:intl/intl.dart'; // For date formatting

enum OrderStatus {
  pending,      // Order placed, waiting for restaurant/agent
  preparing,    // Restaurant is preparing the meal
  readyForPickup, // Meal/ingredients ready for agent pickup
  onTheWay,     // Agent has picked up and is delivering
  delivered,    // Order successfully delivered
  cancelled,    // Order cancelled
}

class OrderItem {
  final String name;
  final int quantity;
  final double unitPrice; // Price per item for meals or estimate for ingredient bundles

  OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}

class Order {
  final String id;
  final String clientId;
  final String clientName;
  final String clientAddress;
  final List<OrderItem> items;
  final DateTime orderDate;
  OrderStatus status;
  String? deliveryAgentId; // Null if not yet assigned
  String? deliveryAgentName; // Null if not yet assigned
  final double deliveryFee; // Can be fixed or vary
  final String pickupLocation; // Restaurant name or 'Local Market' for ingredients
  final String orderType; // 'meal' or 'ingredients'

  Order({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientAddress,
    required this.items,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.deliveryAgentId,
    this.deliveryAgentName,
    required this.deliveryFee,
    required this.pickupLocation,
    required this.orderType,
  });

  double get totalOrderPrice {
    double itemTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    return itemTotal + deliveryFee;
  }

  // Helper to get formatted date
  String get formattedOrderDate => DateFormat('MMM d, yyyy HH:mm').format(orderDate);

  // Static dummy data for demonstration purposes
  static List<Order> dummyOrders = [
    Order(
      id: 'ord1',
      clientId: 'clientA',
      clientName: 'Alice Johnson',
      clientAddress: '123 Main St, Buea',
      items: [
        OrderItem(name: 'Chicken Biryani', quantity: 2, unitPrice: 5000),
      ],
      orderDate: DateTime.now().subtract(Duration(minutes: 45)),
      status: OrderStatus.readyForPickup,
      deliveryFee: 500,
      pickupLocation: 'The Spicy Spoon',
      orderType: 'meal',
    ),
    Order(
      id: 'ord2',
      clientId: 'clientB',
      clientName: 'Bob Williams',
      clientAddress: '456 Oak Ave, Molyko',
      items: [
        OrderItem(name: 'All-purpose flour', quantity: 1, unitPrice: 1500),
        OrderItem(name: 'Yeast', quantity: 1, unitPrice: 500),
      ],
      orderDate: DateTime.now().subtract(Duration(minutes: 60)),
      status: OrderStatus.pending,
      deliveryFee: 600,
      pickupLocation: 'Local Market',
      orderType: 'ingredients',
    ),
    Order(
      id: 'ord3',
      clientId: 'clientC',
      clientName: 'Charlie Brown',
      clientAddress: '789 Pine Ln, Great Soppo',
      items: [
        OrderItem(name: 'Margherita Pizza', quantity: 1, unitPrice: 6000),
        OrderItem(name: 'Coca-Cola (Large)', quantity: 1, unitPrice: 1000),
      ],
      orderDate: DateTime.now().subtract(Duration(minutes: 30)),
      status: OrderStatus.pending,
      deliveryFee: 550,
      pickupLocation: 'Pizzeria Bella',
      orderType: 'meal',
    ),
    Order(
      id: 'ord4',
      clientId: 'clientD',
      clientName: 'Diana Prince',
      clientAddress: '101 Wonder St, Mile 17',
      items: [
        OrderItem(name: 'Ndolé & Plantains', quantity: 1, unitPrice: 4000),
      ],
      orderDate: DateTime.now().subtract(Duration(days: 1, minutes: 120)),
      status: OrderStatus.delivered,
      deliveryAgentId: 'agent1',
      deliveryAgentName: 'David Eposi',
      deliveryFee: 500,
      pickupLocation: 'Mama Africa Delights',
      orderType: 'meal',
    ),
  ];
}