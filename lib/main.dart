// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/client/client_dashboard.dart';
import 'screens/delivery_agent/delivery_agent_dashboard.dart';
import 'screens/restaurant/restaurant_dashboard.dart';
import 'screens/client/restaurant_menu_screen.dart';
import 'utils/theme.dart';
import 'models/restaurant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MopTasteApp());
}

class MopTasteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MopTaste - Buea',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/client-dashboard': (context) => ClientDashboard(),
        '/delivery-agent-dashboard': (context) => DeliveryAgentDashboard(),
        '/restaurant-dashboard': (context) => RestaurantDashboard(),
        '/restaurant-menu': (context) {
          final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;
          return RestaurantMenuScreen(restaurant: restaurant);
        },
      },
    );
  }
}
