// lib/models/order.dart
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  inProgress,
  delivered,
  cancelled,
}

class OrderItem {
  final String name;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  // Create from Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String clientId;
  final String clientName;
  final String clientAddress;
  final List<OrderItem> items;
  final DateTime orderDate;
  final OrderStatus status;
  final String? deliveryAgentId;
  final String? deliveryAgentName;
  final double deliveryFee;
  final String pickupLocation;
  final String orderType;
  final String? restaurantId;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

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
    this.restaurantId,
    required this.totalAmount,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
  });

  // Helper to get formatted date
  String get formattedOrderDate => DateFormat('MMM d, yyyy HH:mm').format(orderDate);

  // Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientAddress': clientAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'orderDate': orderDate.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'deliveryAgentId': deliveryAgentId,
      'deliveryAgentName': deliveryAgentName,
      'deliveryFee': deliveryFee,
      'pickupLocation': pickupLocation,
      'orderType': orderType,
      'restaurantId': restaurantId,
      'totalAmount': totalAmount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
    };
  }

  // Create from Map (local storage)
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientAddress: map['clientAddress'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item))
          .toList() ?? [],
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate'] ?? 0),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAgentId: map['deliveryAgentId'],
      deliveryAgentName: map['deliveryAgentName'],
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      pickupLocation: map['pickupLocation'] ?? '',
      orderType: map['orderType'] ?? 'meal',
      restaurantId: map['restaurantId'],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      deliveredAt: map['deliveredAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveredAt'])
          : null,
    );
  }

  // Convert to JSON string for storage
  String toJson() => json.encode(toMap());

  // Create from JSON string
  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  // Copy with method for updates
  Order copyWith({
    OrderStatus? status,
    String? deliveryAgentId,
    String? deliveryAgentName,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id,
      clientId: clientId,
      clientName: clientName,
      clientAddress: clientAddress,
      items: items,
      orderDate: orderDate,
      status: status ?? this.status,
      deliveryAgentId: deliveryAgentId ?? this.deliveryAgentId,
      deliveryAgentName: deliveryAgentName ?? this.deliveryAgentName,
      deliveryFee: deliveryFee,
      pickupLocation: pickupLocation,
      orderType: orderType,
      restaurantId: restaurantId,
      totalAmount: totalAmount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}