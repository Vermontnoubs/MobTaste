// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart'; // Import your custom theme

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  _checkAuthStatus() async {
    // Simulate a loading time for the splash screen
    await Future.delayed(Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userRole = prefs.getString('userRole') ?? '';

    if (isLoggedIn) {
      // Navigate based on the user's role
      if (userRole == 'delivery_agent') {
        Navigator.pushReplacementNamed(context, '/delivery-agent-dashboard');
      } else if (userRole == 'restaurant') {
        Navigator.pushReplacementNamed(context, '/restaurant-dashboard');
      } else { // Default to client if role is not specified or is 'client'
        Navigator.pushReplacementNamed(context, '/client-dashboard');
      }
    } else {
      // If not logged in, go to the login screen
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