// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'client'; // Default role
  bool _isLoading = false;

  _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userRole', _selectedRole);
      await prefs.setString('userPhone', _phoneController.text);

      setState(() => _isLoading = false);

      if (_selectedRole == 'delivery_agent') {
        Navigator.pushReplacementNamed(context, '/delivery-agent-dashboard');
      } else if (_selectedRole == 'restaurant') {
        Navigator.pushReplacementNamed(context, '/restaurant-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/client-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up for MopTaste'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center( // Center the content
            child: SingleChildScrollView( // Make it scrollable for smaller screens
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Your Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryOrange),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Join MopTaste today!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: AppTheme.primaryOrange),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone, color: AppTheme.primaryOrange),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Your Role:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutralBlack),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.only(top: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('Client (Order food/ingredients)'),
                            value: 'client',
                            groupValue: _selectedRole,
                            onChanged: (value) => setState(() => _selectedRole = value!),
                            activeColor: AppTheme.primaryOrange,
                          ),
                          RadioListTile<String>(
                            title: Text('Delivery Agent (Deliver orders)'),
                            value: 'delivery_agent',
                            groupValue: _selectedRole,
                            onChanged: (value) => setState(() => _selectedRole = value!),
                            activeColor: AppTheme.primaryOrange,
                          ),
                          RadioListTile<String>(
                            title: Text('Restaurant (Sell food/recipes)'),
                            value: 'restaurant',
                            groupValue: _selectedRole,
                            onChanged: (value) => setState(() => _selectedRole = value!),
                            activeColor: AppTheme.primaryOrange,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      child: _isLoading
                          ? CircularProgressIndicator(color: AppTheme.neutralWhite)
                          : Text('Create Account'),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Go back to login
                      child: Text(
                        'Already have an account? Login',
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