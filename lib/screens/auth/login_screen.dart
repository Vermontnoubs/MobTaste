// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', _emailController.text);

      // For demo purposes, determine role based on email or pre-registered data
      // In a real app, this would come from your backend authentication
      String role = 'client'; // Default role

      if (_emailController.text.contains('delivery')) {
        role = 'delivery_agent';
      } else if (_emailController.text.contains('restaurant')) {
        role = 'restaurant';
      }

      await prefs.setString('userRole', role);
      await prefs.setString('userName', 'Test User ($role)'); // Set a dummy name for testing

      setState(() => _isLoading = false);

      if (role == 'delivery_agent') {
        Navigator.pushReplacementNamed(context, '/delivery-agent-dashboard');
      } else if (role == 'restaurant') {
        Navigator.pushReplacementNamed(context, '/restaurant-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/client-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center( // Center the content
            child: SingleChildScrollView( // Make it scrollable for smaller screens
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
                  children: [
                    Text(
                      'Welcome Back to MopTaste!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryOrange),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Login to continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: AppTheme.primaryOrange),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppTheme.primaryOrange),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? CircularProgressIndicator(color: AppTheme.neutralWhite)
                          : Text('Login'),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(color: AppTheme.accentRed), // Use accent red for links
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}