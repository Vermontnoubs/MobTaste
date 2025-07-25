// lib/screens/delivery_agent/delivery_agent_dashboard.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';
import '../../models/order.dart'; // Import the Order model

class DeliveryAgentDashboard extends StatefulWidget {
  @override
  _DeliveryAgentDashboardState createState() => _DeliveryAgentDashboardState();
}

class _DeliveryAgentDashboardState extends State<DeliveryAgentDashboard> with SingleTickerProviderStateMixin {
  String userName = '';
  String userId = ''; // To simulate agent ID
  List<Order> _availableOrders = [];
  List<Order> _acceptedOrders = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Delivery Agent';
      // In a real app, you'd get the actual user ID from the backend
      userId = 'agent1'; // Using a dummy ID for testing purposes
    });
  }

  // Simulate fetching orders (real-world would be API calls)
  _fetchOrders() {
    setState(() {
      // Filter dummy orders based on status for available/accepted
      _availableOrders = Order.dummyOrders.where((order) =>
      (order.status == OrderStatus.pending || order.status == OrderStatus.readyForPickup) &&
          order.deliveryAgentId == null // Only show orders not yet accepted by anyone
      ).toList();

      _acceptedOrders = Order.dummyOrders.where((order) =>
      order.deliveryAgentId == userId &&
          (order.status == OrderStatus.readyForPickup || order.status == OrderStatus.onTheWay)
      ).toList();
    });
  }

  _acceptOrder(Order order) {
    setState(() {
      // Simulate assigning the order to this agent
      order.deliveryAgentId = userId;
      order.deliveryAgentName = userName;
      order.status = OrderStatus.readyForPickup; // Assuming it's ready for pickup after acceptance
      _availableOrders.removeWhere((o) => o.id == order.id);
      _acceptedOrders.add(order);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.id} accepted!'),
        backgroundColor: AppTheme.primaryOrange,
      ),
    );
  }

  _rejectOrder(Order order) {
    setState(() {
      // In a real app, this would notify the backend to re-list the order
      _availableOrders.removeWhere((o) => o.id == order.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.id} rejected.'),
        backgroundColor: AppTheme.accentRed,
      ),
    );
  }

  _updateOrderStatus(Order order, OrderStatus newStatus) {
    setState(() {
      order.status = newStatus;
      // If delivered, remove from accepted list
      if (newStatus == OrderStatus.delivered || newStatus == OrderStatus.cancelled) {
        _acceptedOrders.removeWhere((o) => o.id == order.id);
        // In a real app, delivered orders might go to a history tab
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.id} status updated to ${newStatus.toString().split('.').last}!'),
        backgroundColor: AppTheme.primaryOrange,
      ),
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
        title: Text('Delivery Agent Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Available Orders', icon: Icon(Icons.list_alt)),
            Tab(text: 'My Accepted Orders', icon: Icon(Icons.delivery_dining)),
          ],
          labelColor: AppTheme.neutralWhite,
          unselectedLabelColor: AppTheme.neutralWhite.withOpacity(0.7),
          indicatorColor: AppTheme.primaryYellow,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Available Orders Tab
          _buildOrderList(_availableOrders, isAvailable: true),
          // My Accepted Orders Tab
          _buildOrderList(_acceptedOrders, isAvailable: false),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, {required bool isAvailable}) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isAvailable ? 'No available orders at the moment.' : 'No accepted orders yet.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          isAvailable: isAvailable,
          onAccept: _acceptOrder,
          onReject: _rejectOrder,
          onUpdateStatus: _updateOrderStatus,
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isAvailable; // True if this is an order for acceptance, false if already accepted
  final Function(Order) onAccept;
  final Function(Order) onReject;
  final Function(Order, OrderStatus) onUpdateStatus;

  const OrderCard({
    Key? key,
    required this.order,
    required this.isAvailable,
    required this.onAccept,
    required this.onReject,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusIcon = Icons.pending_actions;
        statusColor = AppTheme.primaryYellow;
        statusText = 'Pending';
        break;
      case OrderStatus.preparing:
        statusIcon = Icons.hourglass_bottom;
        statusColor = AppTheme.primaryYellow;
        statusText = 'Preparing';
        break;
      case OrderStatus.readyForPickup:
        statusIcon = Icons.restaurant_menu;
        statusColor = AppTheme.primaryOrange;
        statusText = 'Ready for Pickup';
        break;
      case OrderStatus.onTheWay:
        statusIcon = Icons.delivery_dining;
        statusColor = AppTheme.lightGrey; // Using lightGrey for on-the-way, perhaps too light. Changed to green.
        statusColor = Colors.green; // Better for on the way
        statusText = 'On The Way';
        break;
      case OrderStatus.delivered:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Delivered';
        break;
      case OrderStatus.cancelled:
        statusIcon = Icons.cancel;
        statusColor = AppTheme.accentRed;
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
              'For: ${order.clientName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.neutralBlack),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: AppTheme.accentRed),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Pickup: ${order.pickupLocation}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.person_pin_circle, size: 18, color: AppTheme.primaryOrange),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Delivery: ${order.clientAddress}',
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
                  'Delivery Fee:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'FCFA ${order.deliveryFee.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'FCFA ${order.totalOrderPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),
            if (isAvailable)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onReject(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentRed,
                        side: BorderSide(color: AppTheme.accentRed),
                      ),
                      child: Text('Reject'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onAccept(order),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                      child: Text('Accept'),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (order.status == OrderStatus.readyForPickup)
                    ElevatedButton(
                      onPressed: () => onUpdateStatus(order, OrderStatus.onTheWay),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                      child: Text('Mark as Picked Up'),
                    )
                  else if (order.status == OrderStatus.onTheWay)
                    ElevatedButton(
                      onPressed: () => onUpdateStatus(order, OrderStatus.delivered),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                      child: Text('Mark as Delivered'),
                    ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Simulate navigation to a map/route screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navigating to client location for order ${order.id}...')),
                      );
                    },
                    child: Text('View on Map', style: TextStyle(color: AppTheme.lightGrey)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}