// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../controllers/auth_service.dart';
import '../models/user.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  _checkAuthStatus() async {
    // Simulate a loading time for the splash screen
    await Future.delayed(Duration(seconds: 2));

    try {
      await _authService.initialize();
      final appUser = await _authService.getCurrentAppUser();
      
      if (appUser != null) {
        // Navigate based on user role
        switch (appUser.role) {
          case UserRole.client:
            Navigator.pushReplacementNamed(context, '/client-dashboard');
            break;
          case UserRole.restaurant:
            Navigator.pushReplacementNamed(context, '/restaurant-dashboard');
            break;
          case UserRole.deliveryAgent:
            Navigator.pushReplacementNamed(context, '/delivery-agent-dashboard');
            break;
        }
      } else {
        // No user signed in, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Error occurred, go to login
      print('Error checking auth status: $e');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange, // Use your defined primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MopTaste Logo Placeholder
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.neutralWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neutralBlack.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'MopTaste',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Your Taste, Delivered.',
              style: TextStyle(
                color: AppTheme.neutralWhite,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neutralWhite),
            ),
          ],
        ),
      ),
    );
  }
}