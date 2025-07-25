// lib/controllers/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final orderData = {
        'clientId': clientId,
        'clientName': clientName,
        'clientAddress': clientAddress,
        'items': items.map((item) => {
          'name': item.name,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
        }).toList(),
        'orderDate': FieldValue.serverTimestamp(),
        'status': OrderStatus.pending.toString().split('.').last,
        'deliveryAgentId': null,
        'deliveryAgentName': null,
        'deliveryFee': deliveryFee,
        'pickupLocation': pickupLocation,
        'orderType': orderType,
        'restaurantId': restaurantId,
        'totalAmount': items.fold(0.0, (sum, item) => sum + item.totalPrice) + deliveryFee,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('orders').add(orderData);
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get orders for client
  Future<List<Order>> getClientOrders(String clientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return _orderFromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting client orders: $e');
      return [];
    }
  }

  // Get orders for restaurant
  Future<List<Order>> getRestaurantOrders(String restaurantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('orderType', isEqualTo: 'meal')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return _orderFromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting restaurant orders: $e');
      return [];
    }
  }

  // Get orders for delivery agent
  Future<List<Order>> getDeliveryAgentOrders(String agentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('deliveryAgentId', isEqualTo: agentId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return _orderFromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting delivery agent orders: $e');
      return [];
    }
  }

  // Get available orders for delivery agents
  Future<List<Order>> getAvailableOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', whereIn: ['readyForPickup', 'preparing'])
          .where('deliveryAgentId', isEqualTo: null)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        return _orderFromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting available orders: $e');
      return [];
    }
  }

  // Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? deliveryAgentId,
    String? deliveryAgentName,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (deliveryAgentId != null) {
        updateData['deliveryAgentId'] = deliveryAgentId;
      }
      if (deliveryAgentName != null) {
        updateData['deliveryAgentName'] = deliveryAgentName;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Assign delivery agent to order
  Future<bool> assignDeliveryAgent({
    required String orderId,
    required String agentId,
    required String agentName,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'deliveryAgentId': agentId,
        'deliveryAgentName': agentName,
        'status': OrderStatus.onTheWay.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error assigning delivery agent: $e');
      return false;
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return _orderFromFirestore(doc);
      }
    } catch (e) {
      print('Error getting order by ID: $e');
    }
    return null;
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  // Get order statistics for restaurant
  Future<Map<String, dynamic>> getRestaurantOrderStats(String restaurantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      int totalOrders = querySnapshot.docs.length;
      int completedOrders = 0;
      double totalRevenue = 0.0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String;
        if (status == 'delivered') {
          completedOrders++;
          totalRevenue += (data['totalAmount'] ?? 0.0).toDouble();
        }
      }

      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'totalRevenue': totalRevenue,
        'pendingOrders': totalOrders - completedOrders,
      };
    } catch (e) {
      print('Error getting restaurant order stats: $e');
      return {
        'totalOrders': 0,
        'completedOrders': 0,
        'totalRevenue': 0.0,
        'pendingOrders': 0,
      };
    }
  }

  // Helper method to convert Firestore document to Order
  Order _orderFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Order(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientAddress: data['clientAddress'] ?? '',
      items: (data['items'] as List<dynamic>?)?.map((item) => 
        OrderItem(
          name: item['name'] ?? '',
          quantity: (item['quantity'] ?? 0).toInt(),
          unitPrice: (item['unitPrice'] ?? 0.0).toDouble(),
        )
      ).toList() ?? [],
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAgentId: data['deliveryAgentId'],
      deliveryAgentName: data['deliveryAgentName'],
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      pickupLocation: data['pickupLocation'] ?? '',
      orderType: data['orderType'] ?? 'meal',
    );
  }

  // Listen to order updates (for real-time updates)
  Stream<List<Order>> listenToClientOrders(String clientId) {
    return _firestore
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => _orderFromFirestore(doc)).toList()
        );
  }

  Stream<List<Order>> listenToRestaurantOrders(String restaurantId) {
    return _firestore
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('orderType', isEqualTo: 'meal')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => _orderFromFirestore(doc)).toList()
        );
  }

  Stream<List<Order>> listenToDeliveryAgentOrders(String agentId) {
    return _firestore
        .collection('orders')
        .where('deliveryAgentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => _orderFromFirestore(doc)).toList()
        );
  }
}