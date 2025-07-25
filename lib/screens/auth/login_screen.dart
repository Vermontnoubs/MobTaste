// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../controllers/auth_service.dart';
import '../../models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (result.success && result.user != null) {
          // Navigate based on user role
          switch (result.user!.role) {
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
          _showErrorDialog(result.message);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to receive a password reset link.'),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final result = await _authService.resetPassword(emailController.text.trim());
                Navigator.pop(context);
                _showInfoDialog(result.message);
              }
            },
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Information'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppTheme.primaryOrange),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(color: AppTheme.accentRed),
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