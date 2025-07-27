// lib/controllers/order_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  static const String _ordersKey = 'orders';

  // Create new order
  Future<String?> createOrder({
    required String clientId,
    required String clientName,
    required String clientAddress,
    required List<OrderItem> items,
    required double deliveryFee,
    required String pickupLocation,
    required String orderType,
    String? restaurantId,
  }) async {
    try {
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice) + deliveryFee;
      
      final order = Order(
        id: orderId,
        clientId: clientId,
        clientName: clientName,
        clientAddress: clientAddress,
        items: items,
        orderDate: DateTime.now(),
        status: OrderStatus.pending,
        deliveryFee: deliveryFee,
        pickupLocation: pickupLocation,
        orderType: orderType,
        restaurantId: restaurantId,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
      );

      await _saveOrder(order);
      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get orders for client
  Future<List<Order>> getOrdersForClient(String clientId) async {
    try {
      final orders = await _getAllOrders();
      return orders.where((order) => order.clientId == clientId).toList()
        ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    } catch (e) {
      print('Error getting client orders: $e');
      return [];
    }
  }

  // Get orders for restaurant
  Future<List<Order>> getOrdersForRestaurant(String restaurantId) async {
    try {
      final orders = await _getAllOrders();
      return orders.where((order) => order.restaurantId == restaurantId).toList()
        ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    } catch (e) {
      print('Error getting restaurant orders: $e');
      return [];
    }
  }

  // Get orders for delivery agent
  Future<List<Order>> getOrdersForDeliveryAgent(String deliveryAgentId) async {
    try {
      final orders = await _getAllOrders();
      return orders.where((order) => order.deliveryAgentId == deliveryAgentId).toList()
        ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    } catch (e) {
      print('Error getting delivery agent orders: $e');
      return [];
    }
  }

  // Get available orders for delivery (pending orders without assigned agent)
  Future<List<Order>> getAvailableOrdersForDelivery() async {
    try {
      final orders = await _getAllOrders();
      return orders.where((order) => 
        order.status == OrderStatus.confirmed && 
        order.deliveryAgentId == null
      ).toList()
        ..sort((a, b) => a.orderDate.compareTo(b.orderDate));
    } catch (e) {
      print('Error getting available orders: $e');
      return [];
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final orders = await _getAllOrders();
      final index = orders.indexWhere((order) => order.id == orderId);
      
      if (index != -1) {
        final order = orders[index];
        final updatedOrder = order.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        
        orders[index] = updatedOrder;
        await _saveAllOrders(orders);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Assign delivery agent to order
  Future<bool> assignDeliveryAgent({
    required String orderId,
    required String deliveryAgentId,
    required String deliveryAgentName,
  }) async {
    try {
      final orders = await _getAllOrders();
      final index = orders.indexWhere((order) => order.id == orderId);
      
      if (index != -1) {
        final order = orders[index];
        final updatedOrder = order.copyWith(
          deliveryAgentId: deliveryAgentId,
          deliveryAgentName: deliveryAgentName,
          status: OrderStatus.inProgress,
          updatedAt: DateTime.now(),
        );
        
        orders[index] = updatedOrder;
        await _saveAllOrders(orders);
        return true;
      }
      return false;
    } catch (e) {
      print('Error assigning delivery agent: $e');
      return false;
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final orders = await _getAllOrders();
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final orders = await _getAllOrders();
      final index = orders.indexWhere((order) => order.id == orderId);
      
      if (index != -1) {
        final order = orders[index];
        if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed) {
          final updatedOrder = order.copyWith(
            status: OrderStatus.cancelled,
            updatedAt: DateTime.now(),
          );
          
          orders[index] = updatedOrder;
          await _saveAllOrders(orders);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  // Complete delivery
  Future<bool> completeDelivery(String orderId) async {
    try {
      final orders = await _getAllOrders();
      final index = orders.indexWhere((order) => order.id == orderId);
      
      if (index != -1) {
        final order = orders[index];
        final updatedOrder = order.copyWith(
          status: OrderStatus.delivered,
          deliveredAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        orders[index] = updatedOrder;
        await _saveAllOrders(orders);
        return true;
      }
      return false;
    } catch (e) {
      print('Error completing delivery: $e');
      return false;
    }
  }

  // Get order statistics for restaurant
  Future<Map<String, dynamic>> getRestaurantOrderStats(String restaurantId) async {
    try {
      final orders = await _getAllOrders();
      final restaurantOrders = orders.where((order) => order.restaurantId == restaurantId).toList();
      
      final totalOrders = restaurantOrders.length;
      final totalRevenue = restaurantOrders
          .where((order) => order.status == OrderStatus.delivered)
          .fold(0.0, (sum, order) => sum + order.totalAmount);
      
      final pendingOrders = restaurantOrders
          .where((order) => order.status == OrderStatus.pending)
          .length;
      
      final completedOrders = restaurantOrders
          .where((order) => order.status == OrderStatus.delivered)
          .length;

      return {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
      };
    } catch (e) {
      print('Error getting restaurant stats: $e');
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'pendingOrders': 0,
        'completedOrders': 0,
      };
    }
  }

  // Get order statistics for delivery agent
  Future<Map<String, dynamic>> getDeliveryAgentStats(String deliveryAgentId) async {
    try {
      final orders = await _getAllOrders();
      final agentOrders = orders.where((order) => order.deliveryAgentId == deliveryAgentId).toList();
      
      final totalDeliveries = agentOrders.length;
      final completedDeliveries = agentOrders
          .where((order) => order.status == OrderStatus.delivered)
          .length;
      
      final totalEarnings = agentOrders
          .where((order) => order.status == OrderStatus.delivered)
          .fold(0.0, (sum, order) => sum + order.deliveryFee);
      
      final pendingDeliveries = agentOrders
          .where((order) => order.status == OrderStatus.inProgress)
          .length;

      return {
        'totalDeliveries': totalDeliveries,
        'completedDeliveries': completedDeliveries,
        'totalEarnings': totalEarnings,
        'pendingDeliveries': pendingDeliveries,
      };
    } catch (e) {
      print('Error getting delivery agent stats: $e');
      return {
        'totalDeliveries': 0,
        'completedDeliveries': 0,
        'totalEarnings': 0.0,
        'pendingDeliveries': 0,
      };
    }
  }

  // Private helper methods
  Future<List<Order>> _getAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_ordersKey);
    if (ordersJson != null) {
      final List<dynamic> ordersList = json.decode(ordersJson);
      return ordersList.map((data) => Order.fromMap(data)).toList();
    }
    return [];
  }

  Future<void> _saveAllOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = json.encode(orders.map((order) => order.toMap()).toList());
    await prefs.setString(_ordersKey, ordersJson);
  }

  Future<void> _saveOrder(Order order) async {
    final orders = await _getAllOrders();
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      orders[index] = order;
    } else {
      orders.add(order);
    }
    await _saveAllOrders(orders);
  }
}