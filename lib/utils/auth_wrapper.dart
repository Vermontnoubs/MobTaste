// lib/utils/auth_wrapper.dart
import 'package:flutter/material.dart';
import '../controllers/auth_service.dart';
import '../models/user.dart';
import '../screens/auth/login_screen.dart';
import '../screens/client/client_dashboard.dart';
import '../screens/restaurant/restaurant_dashboard.dart';
import '../screens/delivery_agent/delivery_agent_dashboard.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _isLoading = true;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await _authService.initialize();
      final user = await _authService.getCurrentAppUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser != null) {
      // User is signed in, navigate based on role
      switch (_currentUser!.role) {
        case UserRole.client:
          return ClientDashboard();
        case UserRole.restaurant:
          return RestaurantDashboard();
        case UserRole.deliveryAgent:
          return DeliveryAgentDashboard();
      }
    }

    // User is not signed in
    return LoginScreen();
  }
}