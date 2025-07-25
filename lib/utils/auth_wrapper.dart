// lib/utils/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_service.dart';
import '../models/user.dart';
import '../screens/auth/login_screen.dart';
import '../screens/client/client_dashboard.dart';
import '../screens/restaurant/restaurant_dashboard.dart';
import '../screens/delivery_agent/delivery_agent_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, get their profile and navigate accordingly
          return FutureBuilder<AppUser?>(
            future: _authService.getCurrentAppUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final user = userSnapshot.data!;
                switch (user.role) {
                  case UserRole.client:
                    return ClientDashboard();
                  case UserRole.restaurant:
                    return RestaurantDashboard();
                  case UserRole.deliveryAgent:
                    return DeliveryAgentDashboard();
                }
              }

              // If no user data found, sign out and go to login
              _authService.signOut();
              return LoginScreen();
            },
          );
        }

        // User is not signed in
        return LoginScreen();
      },
    );
  }
}